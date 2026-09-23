"""Check the hand-authored GitHub Pages guide before deployment."""

from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlparse


ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / 'site'


class GuideParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.ids = set()
        self.duplicates = set()
        self.references = []
        self.images = []
        self.copy_sources = []

    def handle_starttag(self, tag, attributes):
        attrs = dict(attributes)
        identifier = attrs.get('id')
        if identifier:
            if identifier in self.ids:
                self.duplicates.add(identifier)
            self.ids.add(identifier)
        for key in ('href', 'src'):
            value = attrs.get(key)
            if value:
                self.references.append(value)
        if tag == 'img':
            self.images.append(attrs)
        if attrs.get('data-copy'):
            self.copy_sources.append(attrs['data-copy'])


def main():
    page = SITE / 'index.html'
    parser = GuideParser()
    parser.feed(page.read_text(encoding='utf-8'))
    assert not parser.duplicates, f'duplicate HTML IDs: {parser.duplicates}'
    assert all('alt' in image for image in parser.images), 'image missing alt text'
    assert all(identifier in parser.ids for identifier in parser.copy_sources), 'copy button missing source'
    for value in parser.references:
        parsed = urlparse(value)
        if parsed.scheme in ('http', 'https'):
            continue
        assert not parsed.scheme and not parsed.netloc, f'unexpected URL: {value}'
        if parsed.path:
            assert (SITE / parsed.path).is_file() or parsed.path == './logo.png', f'missing local file: {value}'
        if parsed.fragment:
            assert parsed.fragment in parser.ids, f'missing section: {value}'
    for section in ('first-addon', 'safe-reads', 'api', 'pitfalls', 'workflow', 'references'):
        assert section in parser.ids, f'missing guide section: {section}'
    assert (ROOT / 'assets/branding/forever-classmate-logo.png').is_file(), 'missing site logo source'
    print(f'PASS: guide structure, {len(parser.references)} links/assets, and copy targets')


if __name__ == '__main__':
    main()
