class apb_cnfg extends uvm_object;

  uvm_active_passive_enum active = UVM_ACTIVE;

  event sync_start;       

  function new(string name = "apb_cnfg");
    super.new(name);
  endfunction

  	
   // Register to FACTORY
  `uvm_object_utils_begin(apb_cnfg)
  `uvm_field_enum(uvm_active_passive_enum, active, UVM_DEFAULT) 
  `uvm_object_utils_end

endclass