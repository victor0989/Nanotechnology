module kb_keyboard
   (
    input wire TRACEDBGRQ,        // Pin físico E5
    input wire TRACESRST_B,       // Pin físico F6
    output wire TRACETDO          // Pin físico D5
   );

   // Constant declaration
   localparam SP = 8'h20; // Espacio en ASCII

   // Symbolic state declaration
   localparam [1:0]
      idle   = 2'b00,
      send1  = 2'b01,
      send0  = 2'b10,
      sendb  = 2'b11;

   // Signal declaration
   reg [1:0] state_reg, state_next;
   reg [7:0] w_data, ascii_code;
   wire [7:0] scan_data;
   reg wr_uart;
   wire scan_done_tick;
   wire [3:0] hex_in;

   // State register
   always @(posedge TRACEDBGRQ or posedge TRACESRST_B)
      if (TRACESRST_B)
         state_reg <= idle;
      else
         state_reg <= state_next;

   // Next-state logic
   always @*
   begin
      wr_uart = 1'b0;
      w_data = SP;
      state_next = state_reg;
      case (state_reg)
         idle:
            if (scan_done_tick) // A scan code received
               state_next = send1;

         send1: // Send higher hex char
         begin
            w_data = ascii_code;
            wr_uart = 1'b1;
            state_next = send0;
         end

         send0: // Send lower hex char
         begin
            w_data = ascii_code;
            wr_uart = 1'b1;
            state_next = sendb;
         end

         sendb: // Send blank char
         begin
            w_data = SP;
            wr_uart = 1'b1;
            state_next = idle;
         end
      endcase
   end

   // Scan code to ASCII display
   assign hex_in = (state_reg == send1) ? scan_data[7:4] : scan_data[3:0];

   // Hex digit to ASCII code
   always @*
   case (hex_in)
      4'h0: ascii_code = 8'h30; // 0
      4'h1: ascii_code = 8'h31; // 1
      4'h2: ascii_code = 8'h32; // 2
      4'h3: ascii_code = 8'h33; // 3
      4'h4: ascii_code = 8'h34; // 4
      4'h5: ascii_code = 8'h35; // 5
      4'h6: ascii_code = 8'h36; // 6
      4'h7: ascii_code = 8'h37; // 7
      4'h8: ascii_code = 8'h38; // 8
      4'h9: ascii_code = 8'h39; // 9
      4'hA: ascii_code = 8'h41; // A
      4'hB: ascii_code = 8'h42; // B
      4'hC: ascii_code = 8'h43; // C
      4'hD: ascii_code = 8'h44; // D
      default: ascii_code = 8'h20; // Space
   endcase

endmodule

