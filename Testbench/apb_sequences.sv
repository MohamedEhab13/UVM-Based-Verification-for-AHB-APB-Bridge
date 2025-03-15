// Random APB sequence 
class rand_apb_seq extends uvm_sequence #(apb_seq_item);
  `uvm_object_utils(rand_apb_seq)
  
  apb_seq_item apb_transaction ;
  
  function  new(string name = "rand_apb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    apb_transaction = apb_seq_item::type_id::create("apb_transaction") ;
    start_item(apb_transaction) ; 
    assert(apb_transaction.randomize())           
    else
    `uvm_error(get_type_name(),"randomization failed in rand_apb_sequence")  
    finish_item(apb_transaction);	 
  endtask
  
endclass: rand_apb_seq

//-------------------------------------------------------------------------------------------------

// Reset AHB sequence 
class reset_apb_seq extends uvm_sequence #(apb_seq_item);
  `uvm_object_utils(reset_apb_seq)
  
  apb_seq_item apb_transaction ;
  
  function  new(string name = "reset_apb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    apb_transaction = apb_seq_item::type_id::create("apb_transaction") ;
    start_item(apb_transaction) ; 
    assert(apb_transaction.randomize() with {apb_transaction.PRESETn == 0 ;})           
    else
    `uvm_error(get_type_name(),"randomization failed in reset_apb_seq")  
    finish_item(apb_transaction);	 
  endtask
  
endclass: reset_apb_seq

//-------------------------------------------------------------------------------------------------


// OKAY READY apb seq (No error and ready slave responce)               
  class ready_apb_seq extends uvm_sequence #(apb_seq_item);
  `uvm_object_utils(ready_apb_seq)
  
  apb_seq_item apb_transaction ;
  
  function  new(string name = "ready_apb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
     
      apb_transaction = apb_seq_item::type_id::create("apb_transaction") ;
      start_item(apb_transaction) ; 
      assert(apb_transaction.randomize()with {
             apb_transaction.PRESETn == 1 ;
             apb_transaction.PREADY == 1 ;
             apb_transaction.PSLVERR == 0 ;})           
      else
      `uvm_error(get_type_name(),"randomization failed in ready_apb_seq")  
      finish_item(apb_transaction);
  
  endtask 
    
endclass: ready_apb_seq

//------------------------------------------------------------------------------------------------------------

              
  class err_apb_seq extends uvm_sequence #(apb_seq_item);
    `uvm_object_utils(err_apb_seq)
  
  apb_seq_item apb_transaction ;
  
    function  new(string name = "err_apb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
     
      apb_transaction = apb_seq_item::type_id::create("apb_transaction") ;
      start_item(apb_transaction) ; 
      assert(apb_transaction.randomize()with {
             apb_transaction.PRESETn == 1 ;
             apb_transaction.PREADY  == 1 ;
             apb_transaction.PSLVERR == 1 ;})           
      else
        `uvm_error(get_type_name(),"randomization failed in err_apb_seq")  
      finish_item(apb_transaction);
  
  endtask 
    
endclass: err_apb_seq

//------------------------------------------------------------------------------------------------------------

// OKAY BUSY apb seq (No error and not ready slave response)               
  class busy_apb_seq extends uvm_sequence #(apb_seq_item);
    `uvm_object_utils(busy_apb_seq)
  
  apb_seq_item apb_transaction ;
  
  function  new(string name = "busy_apb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
     
      apb_transaction = apb_seq_item::type_id::create("apb_transaction") ;
      start_item(apb_transaction) ; 
      assert(apb_transaction.randomize()with {
             apb_transaction.PRESETn == 1 ;
             apb_transaction.PREADY  == 0 ;
             apb_transaction.PSLVERR == 0 ;})           
      else
      `uvm_error(get_type_name(),"randomization failed in busy_apb_seq")  
      finish_item(apb_transaction);
  
  endtask 
    
endclass: busy_apb_seq

//------------------------------------------------------------------------------------------------------------