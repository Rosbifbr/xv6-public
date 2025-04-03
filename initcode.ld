/* Linker script for xv6 initcode */
/* Modern objdump tooling goes absolutely crazy with the small and simple initcode ELF. This special, simpler script fixes this. */
OUTPUT_FORMAT("elf32-i386", "elf32-i386", "elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(start)

SECTIONS
{
  /* Start code at 0 */
  . = 0;
  .text : {
    *(.text .stub .text.* .gnu.linkonce.t.*)
  }
  . = ALIGN(4);
  .rodata : {
     *(.rodata .rodata.* .gnu.linkonce.r.*)
   }
   /* initcode doesn't typically have writable data or BSS,
      but include placeholders just in case */
  . = ALIGN(4);
  .data : { *(.data) }
  .bss : { *(.bss) }

  /DISCARD/ : { *(.comment .eh_frame .note.GNU-stack .note.gnu.property) }
}
