_start:
    lui     t0, 0x10000         # UART
    auipc   s1, 0
    addi    s1, s1, 256         # Buffer at PC + 256
    mv      s2, s1              # s2 = current pointer
    li      t6, 0               # in comment

wait_for_input:
    # --- 1. Read UART ---
    lbu     t5, 5(t0)           # Check Status
    andi    t5, t5, 1
    beqz    t5, wait_for_input
    lbu     t1, 0(t0)           # t1 = received char
 
    # check end of comment 
    li      t3, 13
    bne     t1, t3, skip_end_comment
    li      t6, 0
skip_end_comment:

    li      t3, 10
    bne     t1, t3, skip_end_comment2
    li      t6, 0
skip_end_comment2:

    li      t3, 35
    bne     t1, t3, skip_start_comment
    li      t6, 1
skip_start_comment:
    li      t3, 1
    beq     t6, t3, wait_for_input

    # --- 2. Check Termination ('.') ---
    li      t3, 46              # ASCII '.'
    beq     t1, t3, start_echo  # EXIT loop if dot detected

    # --- Normalize t1 (ASCII - 48) ---
    mv      t2, t1              # Keep original char in t2
    addi t1, t1, -48          # t1 = char - '0'
    
    # --- Check 0-9 ---
    li      t3, 10              # Load 10 for comparison
    bltu    t1, t3, is_hex      # If (char-'0') < 10, it's 0-9
    
    # --- Check A-F ---
    addi    t1, t1, -7          # t1 = char - '0' - 7 (Maps 'A' to 10)
    li      t3, 16              # Load 16 for comparison
    
    # Check if it's between 10 and 15
    blt     t1, t3, check_lower_bound
    j       wait_for_input      # Not hex

check_lower_bound:
    li      t3, 10
    blt     t1, t3, wait_for_input # It was between '9' and 'A' (ASCII 58-64)

is_hex:
    sb      t2, 0(s2)           # Store the ORIGINAL ASCII char (t2)
    addi    s2, s2, 1
    j       wait_for_input

start_echo:
    mv      t4, s1              # t4 = Pointer to start of buffer
echo_loop:
    beq     t4, s2, print_final_nl # If reached end of buffer, go to Newline
    lbu     t1, 0(t4)           # Load char from buffer

wait_tx:
    lbu     t5, 5(t0)           # Read UART Status
    andi    t5, t5, 32          # Mask THRE
    beqz    t5, wait_tx         # Wait if busy
    sb      t1, 0(t0)           # Send Hex Char
    
    addi    t4, t4, 1           # Increment buffer pointer
    j       echo_loop           # Repeat

print_final_nl:
    li      t1, 10              # ASCII '\n'
wait_nl_tx:
    lbu     t5, 5(t0)           # Read Status
    andi    t5, t5, 32          # Mask THRE
    beqz    t5, wait_nl_tx      # Wait if busy
    sb      t1, 0(t0)           # Send Newline

final_spin:
    lui t0, 0x100
    li t1, 0x5555
    sw t1, 0(t0)
    wfi
    j       final_spin

