/**
* Name: SIR
* Based on the internal empty template. 
* Author: tien
* Tags: 
*/


model sir

global {
    int number_S <- 10000;    
    int number_I <- 10 ;
    int number_R <- 0 ;
    
    int number_individuals<- number_S + number_I + number_R;
    
	float beta <- 4/14 ;
	float gamma <- 1/14;
	
	bool is_stop <- false;
	
	float R0 ;
	
	geometry shape <- square(200);
	
	init {
		create Host number: number_S {
        	is_susceptible <- true;
        	is_infected <-  false;
            is_immune <-  false; 
            color <-  #green;
        }
        
        create Host number: number_I {
            is_susceptible <-  false;
            is_infected <-  true;
            is_immune <-  false; 
            color <-  #red; 
       }
       
       create Host number: number_R {
            is_susceptible <-  false;
            is_infected <-  false;
            is_immune <-  true; 
            color <-  #blue; 
       }
       
       
       R0 <- beta/gamma;
		write "Basic Reproduction Number: "+ R0;
   }
    /*int iteration_number <- 1;
    reflex update {
        float value;
        loop times:iteration_number {
            value<-rnd(10.0);
        }
    }*/
     
    
    reflex compute_nb_infected {
   		number_I <- Host count each.is_infected;
   }
   
    reflex compute_nb_susceptible {
   		number_S <- Host count (each.is_susceptible);
   }
   reflex compute_nb_removed {
   		number_R <- Host count (each.is_immune);
   		
   }  
   reflex stop_simulation when: number_I = 0 {
        do pause;
    }
    
}


//Grid used to discretize space 
grid sir_grid width: 100 height: 100 use_individual_shapes: true use_regular_agents: false frequency: 0{
	rgb color <- #black;
}


species Host  {
	//Booleans to represent the state of the host agent
	bool is_susceptible <- true;
	bool is_infected <- false;
    bool is_immune <- false;
    rgb color <- #green;
    sir_grid myPlace;
    
    init {
    	//Place the agent randomly among the grid
    	myPlace <-  one_of (sir_grid as list);
    	location <- myPlace.location;
    }     
  
    reflex become_infected when: is_susceptible{
    		float rate <- beta*number_I/number_individuals;
    		bool results <-  flip(rate);
    		if(results){
        	is_susceptible <-  false;
            is_infected <-  true;
            is_immune <-  false;
            color <-  #red;    
           }
    }
    
    reflex become_immune when: (is_infected and flip(gamma)) {
    	is_susceptible <- false;
    	is_infected <- false;
        is_immune <- true;
        color <- #blue;
    }
    
    
    aspect basic {
        draw circle(1) color: color; 
    }
}

experiment Simulation type: gui{ 
 	parameter "Number of Susceptible" var: number_S ;
 	parameter "Number of Infected" var: number_I ;	// The number of infected
    parameter "Number of Resistant" var:number_R ;	// The number of removed
	parameter "Beta (S->I)" var:beta; 	// The parameter Beta
	parameter "Gamma (I->R)" var: gamma; // The parameter gamma
	
	//float seedValue <- rnd(1.0, 10000.0);
	//float seed <- seedValue;
	//int iterator<-1;
	//int number_simulations <- 2;
	init{
		//create simulation with: [seed::seedValue+1];
		//create simulation with: [seed::seedValue];
    }
	/*reflex when: (number_I = 0){
			create simulation with: [seed::seedValue, iteration_number::2];
			//iterator <- iterator +1;
		}
	*/
	
	//reflex check_stop{
	//	if(iterator = number_simulations){
	//		is_stop <- true;
	//	}
	//}
	 /* 
	reflex end_of_runs {
    int cpt <- 0;
    ask simulation{
        save ( ""+ cycle + "," + number_S 
        	+ "," + number_I
        	+ "," + number_R
        )     
      	to: "result1"   type: "text" rewrite: false;  
    	}
    	cpt <- cpt + 1;  	
    }*/
	
	
    
 	output { 
	    display sir_display {
	        grid sir_grid lines: #black;
	        species Host aspect: basic;
	        
	    }  	
	    	display histogram refresh: every(1#cycle) {
				chart "Susceptible-Infected-Removed Model" type: histogram background: #lightgray style: exploded {
					data "susceptible" value: Host count (each.is_susceptible) color: #green;					
					data "infected" value: Host count (each.is_infected) color: #red;
					data "removed" value: Host count (each.is_immune) color: #blue;
				}
				
			}
			display chart refresh: every(1#cycle) {
				chart "Susceptible-Infected-Removed Model" type: series background: #lightgray style: exploded {
					data "susceptible" value: Host count (each.is_susceptible) color: #green;					
					data "infected" value: Host count (each.is_infected) color: #red;
					data "removed" value: Host count (each.is_immune) color: #blue;
				}
				
			}
				
			monitor "Number of susceptible" value: number_S;	      	
	      	monitor "Number of infected" value: number_I;
	      	monitor "Number of removed" value: number_R;
			
	}
			
}


