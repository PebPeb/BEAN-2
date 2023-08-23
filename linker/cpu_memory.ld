MEMORY
{
  instruction_memory (rx) : ORIGIN = 0x00000000, LENGTH = 256
  data_memory (rwx) : ORIGIN = 0x00010000, LENGTH = 256
}

SECTIONS
{
  .text :
  {
    *(.text)
  } > instruction_memory

  .data :
  {
    *(.data)
    *(.bss)
  } > data_memory


  /* Stack section */
  .stack (NOLOAD) :
  {
    __stack_start = ORIGIN(data_memory) + LENGTH(data_memory); /* Start address of the stack, at the end of data_memory */
    . += STACK_SIZE; /* Increase the current address by the stack size (adjust STACK_SIZE accordingly) */
    . = ALIGN(4); /* Align the stack pointer to a 4-byte boundary */
  } > data_memory

  /* Set the stack pointer to the beginning of the stack */
  __stack_pointer = __stack_start;
  STACK_SIZE = 64;
}
