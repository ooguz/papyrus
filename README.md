
<p align="center">
  <a href="https://github.com/ooguz/papyrus">
    <img src="https://github.com/ooguz/papyrus/assets/17238191/d8bf4dbe-117a-48d0-8905-9849e1119f57" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Papyrus</h3>

  <p align="center">
    A simple paper backup tool
    <br/>
    <br/>
    <a href="https://github.com/ooguz/papyrus/issues">Report Bug</a>
    --
    <a href="https://github.com/ooguz/papyrus/issues">Request Feature</a>
  </p>
</p>

![Downloads](https://img.shields.io/github/downloads/ooguz/papyrus/total) ![Contributors](https://img.shields.io/github/contributors/ooguz/papyrus?color=dark-green) ![Stargazers](https://img.shields.io/github/stars/ooguz/papyrus?style=social) ![Issues](https://img.shields.io/github/issues/ooguz/papyrus) ![License](https://img.shields.io/github/license/ooguz/papyrus) 


## About 

![Screenshot](https://github.com/ooguz/papyrus/assets/17238191/dce455ee-5161-4abc-bf0c-474cc52d4752)

If you are working with GnuPG or SSH, you will probably understand the fear of losing your keys. This tool makes a "hard copy" of your text files including but not limited to your keys, 2FA backups, config files etc. 

Papyrus can produce a PDF output which consist of QR codes made from your file to restore easily, in addition to OCR-friendly plain text version of your file, to prevent any failure on QR codes, with checksums for each line.

My personal recommendation is to print your paper backup with laser printer to acid-free paper, put it into a plastic bag (Mylar is preferred) and seal it with a heat sealer (you can find one around 25 USD, also useful for food packaging).

## Installation

Go to the [Releases](https://github.com/ooguz/papyrus/releases) page and download the package for your distribution and signatures.

### Checksum and signature verification

1. Download release files and checksums
2. Get my GnuPG key to verify checksums

```bash
gpg --keyserver keyserver.ubuntu.com --recv-keys D854D9D85CB4910704BD9C5B2D33E2BD3D975818
```
3. Verify `SHA256SUMS` file by running:

```bash
gpg --verify SHA256SUMS.asc
```
4. Verify SHA256 checksums with:

```bash
sha256sum -c SHA256SUMS
```

### AppImage

Give execution permission to AppImage file and run Papyrus:

```bash
chmod +x papyrus*-linux.AppImage
./papyrus-*.AppImage
```


### Ubuntu/Debian (deb) Package

Install deb package and run Papyrus:

```bash
sudo dpkg -i papyrus*.deb
papyrus
```

## Example output

|QR pages|OCR pages|OCR zebra|
|----|----|----|
|![image](https://github.com/ooguz/papyrus/assets/17238191/6c26d924-b083-431f-9979-086069a2131a)|![image](https://github.com/ooguz/papyrus/assets/17238191/b37a2f86-c0c7-4d3f-a1b8-cb3d3f61c55a)|![image](https://github.com/ooguz/papyrus/assets/17238191/df429ff8-c6a9-4b99-9ed0-66a41cedb84d)|





## Roadmap

* Implement andOTP (or similiar) backup parser function
* Implement password manager (KeePassXC, pass etc.) parser
* Add restore from scan function
* Add custom title and description to PDF

## Contributing

Any contributions you make are **greatly appreciated**.
* If you have suggestions for adding or removing features, feel free to [open an issue](https://github.com/ooguz/papyrus/issues/new) to discuss it, or directly create a pull request after you edit the *README.md* file with necessary changes.
* Please make sure you check your spelling and grammar.
* Create individual PR for each suggestion.

### Creating A Pull Request

1. Fork the project
2. Create your feature branch (`git checkout -b new_feature`)
3. Commit your Changes (`git commit -m 'Add new feature'`)
4. Push to the Branch (`git push origin new_feature`)
5. Open a pull pequest

## License

    Copyright (C) 2023 Özcan Oğuz

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

## Reading

* [Paper Backup - KeePassXC](https://keepassxc.org/blog/2020-10-03-paper-backup/)
* [Why you still need paper hard copy backups?](https://www.norpacpaper.com/blog/why-you-still-need-paper-hard-copy-backups)
