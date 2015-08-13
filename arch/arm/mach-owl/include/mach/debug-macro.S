/*
 * arch/arm/mach-gl5202/include/mach/debug-macro.S
 *
 * Debugging macro include header
 *
 * Copyright 2012 Actions Semi Inc.
 * Author: Actions Semi, Inc.
 *
 * This program is free software; you can redistribute  it and/or modify it
 * under  the terms of  the GNU General  Public License as published by the
 * Free Software Foundation;  either version 2 of the  License, or (at your
 * option) any later version.
 */

#include <mach/hardware.h>

    .macro  addruart, rp, rv, tmp
    ldr     \rp, =UART2_CTL                     @ physical base address
    mrc     p15, 0, \rv, c1, c0
    tst     \rv, #1                             @ MMU enabled?
    beq     100f
    ldr     \rp, =IO_ADDRESS(UART2_CTL)         @ virtual address

100:
    ldr     \rv, [\rp]
    and     \rv, \rv, #0x00008000
    cmp     \rv, #0                             @ is port configured?
    bne     101f
    
    add     \rp, \rp, #0x00002000
    b       100b

101:
    and     \rp, \rp, #0x03ffffff
    orr     \rv, \rp, #0xf8000000               @ virtual
    orr     \rp, \rp, #0xb0000000               @ physical

    .endm

    .macro  senduart,rd,rx
    str     \rd, [\rx, #(UART2_TXDAT - UART2_BASE)] @ Write to Transmitter Holding Register
    .endm

    .macro  busyuart, rd, rx
1001:   
    ldr     \rd, [\rx, #(UART2_STAT - UART2_BASE)]  @ Read Status Register
    tst     \rd, #0x40                          @ TXFIFO Full?
    bne     1001b
    .endm

    .macro  waituart,rd,rx
1001:   
    ldr     \rd, [\rx, #(UART2_STAT - UART2_BASE)]  @ Read Status Register
    tst     \rd, #0x400                         @ TXFIFO Empty?
    beq     1001b
    .endm
