%define PERM 5
%define DEFBITS 64
%defstr ELF_HDR !%HOME/.vim/skel/elf_hdr.mac
%include ELF_HDR


_start:
<>


;ELF_HEADER
filesize	equ	$ - $$
