Name:           harbour-clipshare
Summary:        Shares the clipboard contents
Version:        1.0.0
Release:        1
License:        BSD
URL:            https://github.com/monich/harbour-clipshare
Source0:        %{name}-%{version}.tar.gz

Requires:       sailfishsilica-qt5
Requires:       qt5-qtsvg-plugin-imageformat-svg
BuildRequires:  pkgconfig(sailfishapp)
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5DBus)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  qt5-qttools-linguist

%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%define _binary_payload w6.xzdio

%description
Shares the clipboard contents.

%if "%{?vendor}" == "chum"
Categories:
 - Utility
Icon: https://raw.githubusercontent.com/monich/harbour-clipshare/master/icons/harbour-clipshare.svg
Screenshots:
- https://home.monich.net/chum/harbour-clipshare/screenshots/screenshot-001.png
- https://home.monich.net/chum/harbour-clipshare/screenshots/screenshot-002.png
- https://home.monich.net/chum/harbour-clipshare/screenshots/screenshot-003.png
Url:
  Homepage: https://openrepos.net/content/slava/clip-share
%endif

%prep
%setup -q -n %{name}-%{version}

%build
%qtc_qmake5 %{name}.pro
%qtc_make %{?_smp_mflags}

%install
%qmake5_install

desktop-file-install --delete-original \
  --dir %{buildroot}%{_datadir}/applications \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
