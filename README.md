# Create a Vagrant Basebox for Debian 12 and Hyper-V

Create a Vagrant BaseBox for Hyper-V with a preinstalled Xfce-Desktop.

## Used documentation
- Vagrant / Hyper-V / [Creating a Base Box](https://developer.hashicorp.com/vagrant/docs/providers/hyperv/boxes)
- Hyper-V ISO Packer integration - [Hyper-V ISO](https://developer.hashicorp.com/packer/integrations/hashicorp/hyperv/latest/components/builder/iso)
- Debain - [B.2 Using preseeding](https://www.debian.org/releases/bookworm/amd64/apbs02.en.html)


## Prereqisites
1) Install packer and vagrant and add them to your PATH

2) With the Windows 11 22H2 a Hyper-V Firewall was introduced. You can find further information [here](https://learn.microsoft.com/en-us/windows/security/operating-system-security/network-security/windows-firewall/hyper-v-firewall)

Adjust the Hyper-V Firewall, so that the Guest can download files from the Http-Server that is created by packer. If required adjust the VMCreatorId. 
It can be determined with `Get-NetFirewallHyperVVMCreator`
```
New-NetFirewallHyperVRule -DisplayName "Allow Packer HTTP" -Direction Inbound -VMCreatorId '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}' -Action Allow -Protocol TCP -LocalPort 8000-9000
```

## Usage
- Verify the values for the parameters iso_checksum and iso_url and update them according to the Debian Version you want to install.

- Create the basebox by running:
```
packer build .\debian-netinstall-hyper-v.pkr.hcl
```

- Add basebox to your Vagrant installation by:
```
vagrant box add --provider hyperv my-debian-basebox .\output\my-debian-base.box
```
- To create a virtual machine using the basebox run:
```
vagrant init my-debian-basebox && vagrant up
```

# Register the Basebox to your local vagrant installation
vagrant box add --provider hyperv my-debian-basebox .\output\my-debian-base.box