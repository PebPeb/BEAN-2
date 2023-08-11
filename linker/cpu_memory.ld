MEMORY
{
  memory_region (rwx) : ORIGIN = 0x00000000, LENGTH = 1024
}

SECTIONS
{
  .text :
  {
    *(.text)
  } > memory_region

  .data :
  {
    *(.data)
    *(.bss)
  } > memory_region

  /* Stack section */
  .stack (NOLOAD) :
  {
    __stack_start = ORIGIN(memory_region) + LENGTH(memory_region); /* Start address of the stack, at the end of memory_region */
    . += STACK_SIZE; /* Increase the current address by the stack size (adjust STACK_SIZE accordingly) */
    . = ALIGN(4); /* Align the stack pointer to a 4-byte boundary */
  } > memory_region

  /* Set the stack pointer to the beginning of the stack */
  __stack_pointer = __stack_start;
  STACK_SIZE = 256;
}
