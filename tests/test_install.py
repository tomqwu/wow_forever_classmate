import sys
from pathlib import Path
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).parents[1] / 'scripts'))
from install import detect_client, install_files


class InstallTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / '_forever_').mkdir()
        (self.root / '_classic_beta_').mkdir()
        (self.root / '.build.info').write_text(
            'Product!STRING:0|Active!DEC:1|Version!STRING:0\n'
            'wow_classic_beta|1|2.5.6.70006\nwowf|1|1.60.1.70707\n')

    def test_detects_live_product_over_historical_beta(self):
        self.assertEqual(detect_client(self.root), self.root / '_forever_')
        self.assertEqual(detect_client(self.root, '_classic_beta_'), self.root / '_classic_beta_')

    def test_no_accidental_install_into_unrelated_beta(self):
        (self.root / '.build.info').write_text('Product!STRING:0|Active!DEC:1\nwow_classic_beta|1\nwowf|0\n')
        with self.assertRaises(ValueError):
            detect_client(self.root)
        (self.root / '.build.info').unlink()
        with self.assertRaises(ValueError):
            detect_client(self.root)
        self.assertEqual(detect_client(self.root, '_forever_'), self.root / '_forever_')

    def test_missing_live_folder_does_not_fall_back(self):
        (self.root / '_forever_').rmdir()
        with self.assertRaises(ValueError):
            detect_client(self.root)

    def test_installs_verified_files_and_preserves_edits_and_settings(self):
        source = self.root / 'source'
        source.mkdir()
        (source / 'Main.lua').write_text('-- new code\n')
        destination = self.root / '_forever_/Interface/AddOns/ForeverUtilities'
        destination.mkdir(parents=True)
        (destination / 'Main.lua').write_text('-- user edit\n')
        (destination / 'Extra.txt').write_text('local file')
        settings = self.root / '_forever_/WTF/Account/SavedVariables.lua'
        settings.parent.mkdir(parents=True)
        settings.write_text('user settings')
        backup, count = install_files(source, destination, self.root / 'backups')
        self.assertEqual(count, 1)
        self.assertEqual((destination / 'Main.lua').read_bytes(), (source / 'Main.lua').read_bytes())
        self.assertEqual((backup / 'Main.lua').read_text(), '-- user edit\n')
        self.assertEqual((backup / 'Extra.txt').read_text(), 'local file')
        self.assertEqual((destination / 'Extra.txt').read_text(), 'local file')
        self.assertEqual(settings.read_text(), 'user settings')

    def test_fresh_install_and_unchanged_reinstall(self):
        source = self.root / 'source'
        source.mkdir()
        (source / 'Main.lua').write_bytes(b'-- same\n')
        destination = self.root / 'new-addon'
        self.assertEqual(install_files(source, destination, self.root / 'backups'), (None, 1))
        self.assertEqual(install_files(source, destination, self.root / 'backups'), (None, 1))


if __name__ == '__main__':
    unittest.main()
