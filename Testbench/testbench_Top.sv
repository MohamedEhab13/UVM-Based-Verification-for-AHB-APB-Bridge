`timescale 1ns/1ns
`include "uvm_macros.svh"

module top ; 
  
  import uvm_pkg::*;
  import bridge_pkg::* ;
  
  // AHB and APB clock declaration 
  bit hclk , pclk ;

   
  ahb_intf ahb_intf_h (hclk);  
  apb_intf apb_intf_h (pclk); 
  
  
  ahb3lite_apb_bridge DUT 
                      (// AHB Interface 
                      
                      .HRESETn(ahb_intf_h.HRESETn),
                      .HCLK(hclk),
                      .HSEL(ahb_intf_h.HSEL),
                      .HADDR(ahb_intf_h.HADDR),
                      .HWDATA(ahb_intf_h.HWDATA),
                      .HRDATA(ahb_intf_h.HRDATA),
                      .HWRITE(ahb_intf_h.HWRITE),
                      .HSIZE(ahb_intf_h.HSIZE),
                      .HBURST(ahb_intf_h.HBURST),
                      .HPROT(ahb_intf_h.HPROT),
                      .HTRANS(ahb_intf_h.HTRANS),
                      .HMASTLOCK(1'b1),
                      .HREADYOUT(ahb_intf_h.HREADYOUT),
                      .HREADY(ahb_intf_h.HREADY),
                      .HRESP(ahb_intf_h.HRESP),
                 
                  
                      // APB Interface 
                     .PRESETn(apb_intf_h.PRESETn),
                     .PCLK(pclk),
                     .PSEL(apb_intf_h.PSEL),
                     .PENABLE(apb_intf_h.PENABLE),
                     .PPROT(apb_intf_h.PPROT),
                     .PWRITE(apb_intf_h.PWRITE),
                     .PSTRB(apb_intf_h.PSTRB),
                     .PADDR(apb_intf_h.PADDR),
                     .PWDATA(apb_intf_h.PWDATA),
                     .PRDATA(apb_intf_h.PRDATA),
                     .PREADY(apb_intf_h.PREADY),
                     .PSLVERR(apb_intf_h.PSLVERR)              
                     ) ;
  
  
 // Bind DUT with Assertion 
 bind ahb3lite_apb_bridge Assertions #(
                     .HADDR_SIZE(HADDR_SIZE),  
                     .HDATA_SIZE(HDATA_SIZE),
                     .PADDR_SIZE(PADDR_SIZE),
                     .PDATA_SIZE(PDATA_SIZE)
                     ) 
                     Assertions_inst (
                     // AHB Slave Interface connections
                     .HRESETn   (HRESETn),
                     .HCLK      (HCLK),
                     .HSEL      (HSEL),
                     .HADDR     (HADDR),
                     .HWDATA    (HWDATA),
                     .HRDATA    (HRDATA),
                     .HWRITE    (HWRITE),
                     .HSIZE     (HSIZE),
                     .HBURST    (HBURST),
                     .HPROT     (HPROT),
                     .HTRANS    (HTRANS),
                     .HMASTLOCK (HMASTLOCK),
                     .HREADYOUT (HREADYOUT),
                     .HREADY    (HREADY),
                     .HRESP     (HRESP),
  
                     // APB Master Interface connections
                    .PRESETn   (PRESETn),
                    .PCLK      (PCLK),
                    .PSEL      (PSEL),
                    .PENABLE   (PENABLE),
                    .PPROT     (PPROT),
                    .PWRITE    (PWRITE),
                    .PSTRB     (PSTRB),
                    .PADDR     (PADDR),
                    .PWDATA    (PWDATA),
                    .PRDATA    (PRDATA),
                    .PREADY    (PREADY),
                    .PSLVERR   (PSLVERR)
                    );
  

  
 // Clock Generation 
 initial begin
    forever begin 
       #5  hclk = ~hclk;
    end
  end
  
  // Clock Generation 
 initial begin
    forever begin        
       #10 pclk = ~pclk;
    end
  end
  
  
  
 // Set the virtual interface handles to the config_db 
  initial begin     
    uvm_config_db # (virtual ahb_intf)::set(null,"*","ahb_intf_h",ahb_intf_h); 
    uvm_config_db # (virtual apb_intf)::set(null,"*","apb_intf_h",apb_intf_h);  
    run_test();
  end
  
  
  initial 
  begin
    // Required to dump signals to EPWave
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  
endmodule 
  
  
