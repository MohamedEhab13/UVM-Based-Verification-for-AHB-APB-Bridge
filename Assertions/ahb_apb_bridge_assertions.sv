module Assertions #(
  parameter HADDR_SIZE = 32,
  parameter HDATA_SIZE = 32,
  parameter PADDR_SIZE = 32,
  parameter PDATA_SIZE = 32
)(
  // AHB Slave Interface
  input                         HRESETn,
  input                         HCLK,
  input                         HSEL,
  input      [HADDR_SIZE  -1:0] HADDR,
  input      [HDATA_SIZE  -1:0] HWDATA,
  input      [HDATA_SIZE  -1:0] HRDATA,
  input                         HWRITE,
  input      [             2:0] HSIZE,
  input      [             2:0] HBURST,
  input      [             3:0] HPROT,
  input      [             1:0] HTRANS,
  input                         HMASTLOCK,
  input                         HREADYOUT,
  input                         HREADY,
  input                         HRESP,
  
  // APB Master Interface
  input                         PRESETn,
  input                         PCLK,
  input                         PSEL,
  input                         PENABLE,
  input      [             2:0] PPROT,
  input                         PWRITE,
  input      [PDATA_SIZE/8-1:0] PSTRB,
  input      [PADDR_SIZE  -1:0] PADDR,
  input      [PDATA_SIZE  -1:0] PWDATA,
  input      [PDATA_SIZE  -1:0] PRDATA,
  input                         PREADY,
  input                         PSLVERR
);

  // Define HTRANS values for better readability
  localparam IDLE   = 2'b00;
  localparam BUSY   = 2'b01;
  localparam NONSEQ = 2'b10;
  localparam SEQ    = 2'b11;

   
 //====================================================================================================================
  
  // Property to chech HREADYOUT deassertion when HREADY and HSEL are HIGH while HTRANS is NONSEQ or SEQ
  property p_hreadyout_falls;
    @(posedge HCLK) disable iff (!HRESETn)
    (HREADY && HSEL && ($past(HTRANS) == IDLE) && (HTRANS == NONSEQ)) |-> 
    ##2(!HREADYOUT);
  endproperty

  // Assert the property
  assert_hreadyout_falls: assert property (p_hreadyout_falls)
    else $error("Violation: HREADYOUT did not fall after HREADY=1, HSEL=1, and HTRANS=NONSEQ/SEQ");
  
  // Cover the property  
  cover_hreadyout_falls: cover property (p_hreadyout_falls)
    $display("Covered: HREADYOUT fall after HREADY is HIGH, HSEL is HIGH, and HTRANS=NONSEQ/SEQ");  

 //=====================================================================================================================
    
  // Property to check that signals remain stable when PREADY is low
  property p_pready_low;
  @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && !PREADY) |=> 
      $stable(PENABLE) && 
      $stable(PSEL)    && 
      $stable(PADDR)   && 
      $stable(PWRITE)  && 
      $stable(PWDATA)  && 
      $stable(PSTRB)   && 
      $stable(PPROT)   && 
      $stable(HREADYOUT);
  endproperty

  // Assert the property
  assert_p_pready_low: assert property (p_pready_low)
    else $error("Violation: APB/AHB signals changed while PREADY was low at time %0t", $time);
    
  // Cover the property
  cover_p_pready_low: cover property (p_pready_low)
    $display("Covered: APB/AHB signals unchanged while PREADY was low at time %0t", $time);  
    
 //======================================================================================================================

  // Property to check PENABLE duration
  property p_penable_duration;
  @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && $rose(PENABLE)) |=> 
      (!PENABLE || (PENABLE && !PREADY));
  endproperty

  // Assert the property
  assert_penable_duration: assert property (p_penable_duration)
    else $error("Violation: PENABLE remained high for more than one cycle while PREADY was high at time %0t", $time);
    
  // Cover the property
  cover_penable_duration: cover property (p_penable_duration)
    $display("Covered: PENABLE remained high only one cycle while PREADY was high at time %0t", $time);
    
 //======================================================================================================================
    
  // Property to check HRESP and HREADYOUT timing after PSLVERR
   property p_pslverr_response;
   @(posedge HCLK) disable iff (!HRESETn)
     ($rose(PSLVERR) && PSEL) |-> 
     ##7 $rose(HRESP) ##1 $rose(HREADYOUT);
   endproperty

  // Assert the property
  assert_pslverr_response: assert property (p_pslverr_response)
   else $error("Violation: After PSLVERR, HRESP didn't rise after exactly 7 cycles or HREADYOUT didn't rise 1 cycles after HRESP at time %0t", $time);   
    
  // Cover the property
  cover_pslverr_response: cover property (p_pslverr_response)
    $display("Covered: After PSLVERR, HRESP rose after exactly 7 cycles and HREADYOUT rose 1 cycles after HRESP at time %0t", $time);  
    
 //======================================================================================================================
    
  // Property to check PSEL assertion timing after valid AHB transfer request
  property p_psel_timing;
  @(posedge HCLK) disable iff (!HRESETn)
    (HREADY && HSEL && ($past(HTRANS) == IDLE) && (HTRANS == NONSEQ)) |-> 
      ##7 $rose(PSEL);
  endproperty

  // Assert the property
  assert_psel_timing: assert property (p_psel_timing)
    else $error("Violation: PSEL did not rise exactly 7 cycles after valid AHB transfer request at time %0t", $time); 
    
  // Cover the property
  cover_psel_timing: cover property (p_psel_timing)
    $display("Covered: PSEL rose rose after 7 cycles of valid AHB transfer request at time %0t", $time);  
 
    
endmodule