%define project_name	firefox-gnome-keyring
%define github_user	fat-lobyte

# Mozilla extension ID's and locations
%define moz_ext_dir %{_datadir}/mozilla/extensions
%define src_ext_id \{6f9d85e0-794d-11dd-ad8b-0800200c9a66\}

%define firefox_app_id \{ec8030f7-c20a-464f-9b0e-13a3a9e97384\}
%define inst_dir %{moz_ext_dir}/%{firefox_app_id}/%{src_ext_id}

%define thunderbird_app_id \{3550f703-e582-4d05-9a08-453d09bdfdc6\}
%define thunderbird_inst_dir %{moz_ext_dir}/%{thunderbird_app_id}/%{src_ext_id}


Name:		mozilla-gnome-keyring
Version:	0.6
Release:	3%{?dist}
Summary:	Store mozilla passwords in GNOME Keyring

Group:		Applications/Internet
License:	MPLv1.1
URL:		https://github.com/mdlavin/firefox-gnome-keyring
Source0:	https://github.com/downloads/%{github_user}/%{project_name}/%{project_name}-%{version}.tar.gz

BuildRequires:	xulrunner-devel, libgnome-keyring-devel
Requires:	mozilla-filesystem

%description
This extenion integrates gnome-keyring into xulrunner applications as the software security device.


%prep
%setup -q -n %{project_name}-%{version}


%build
make %{?_smp_mflags} VERSION=%{version}


%install
#clean buildroot
rm -rf %{buildroot}

#install extension
install -dm 755 %{buildroot}%{inst_dir}
cd xpi/
install -Dpm 644 chrome.manifest install.rdf %{buildroot}%{inst_dir}
install -dm 755 %{buildroot}%{inst_dir}/platform/Linux_%{_arch}-gcc3/components/
install -pm 644 platform/Linux_%{_arch}-gcc3/components/libgnomekeyring.so %{buildroot}%{inst_dir}/platform/Linux_%{_arch}-gcc3/components/


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%{inst_dir}
%doc README AUTHORS COPYING LICENSE.GPL-2 LICENSE.LGPL-2.1 LICENSE.MPL-1.1


%changelog
* Sat Dec 31 2011 Alexander Korsunsky <fat.lobyte9@gmail.com> - 0.6-3
- Use version override for building

* Sat Dec 31 2011 Alexander Korsunsky <fat.lobyte9@gmail.com> - 0.6-2
- Install configured install.rdf instead of template
- Use architecture independent directories

* Sat Dec 31 2011 Alexander Korsunsky <fat.lobyte9@gmail.com> - 0.6-1
- Initial Release
