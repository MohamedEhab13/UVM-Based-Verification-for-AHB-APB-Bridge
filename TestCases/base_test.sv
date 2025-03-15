class base_test extends uvm_test ;
  `uvm_component_utils(base_test)

  env env_h ;
   
  ahb_cnfg ahb_cnfg_h ;
  apb_cnfg apb_cnfg_h ;
   
  reset_ahb_seq  ahb_reset_s  ;
  reset_apb_seq  apb_reset_s  ;

  // Constructor 
  function new(string name = "base_test" ,uvm_component parent);
    super.new(name,parent);
  endfunction :new

  // Build Phase 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env_h = env::type_id::create("env_h",this);
    
    ahb_cnfg_h = ahb_cnfg::type_id::create("ahb_cnfg_h");
    apb_cnfg_h = apb_cnfg::type_id::create("apb_cnfg_h");
    
    ahb_reset_s = reset_ahb_seq::type_id::create("ahb_reset_s");
    apb_reset_s = reset_apb_seq::type_id::create("apb_reset_s");
    
    uvm_config_db #(ahb_cnfg)::set(this, "*" , "ahb_configuration" , ahb_cnfg_h);
    uvm_config_db #(apb_cnfg)::set(this, "*" , "apb_configuration" , apb_cnfg_h);
  endfunction : build_phase 

endclass :base_test
