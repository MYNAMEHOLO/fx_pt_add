module fx_pt_add(a,b,sum);

parameter SGN = 2;
parameter WIDTH = 15;
parameter A_INT_W = 14; 
parameter B_INT_W = 1;



input [WIDTH-1:0] a, b; //a,b with WIDTH WIDTH
output [2*WIDTH:0] sum;
reg [2*WIDTH:0] sum; //sum bit有 2*WIDTH+1的寬度




generate
case(SGN)
  0:begin :SGN_0    //finish
    reg [2*WIDTH-1 : 0] a_us , b_us ; // for a unsigned and b signed
    always@(*)begin	
    a_us = {{{B_INT_W}{1'b0}}, a,{{A_INT_W}{1'b0}}};
    b_us = {{{A_INT_W}{1'b0}}, b,{{B_INT_W}{1'b0}}};
    sum = a_us + b_us;
    end
  end

  1:begin :SGN_1
    reg [2*WIDTH:0] a_str, b_str; //a,b with 2*WIDTH+1的寬度
    always@(*)begin  
    a_str = {{{WIDTH-A_INT_W + 1'b1}{a[WIDTH - 1]}},a,{{A_INT_W}{1'b0}}};
    b_str = {{{WIDTH-B_INT_W + 1'b1}{b[WIDTH - 1]}},b,{{B_INT_W}{1'b0}}};
    sum = a_str + b_str;
    end
  end

 
  default:begin :SGN_default 
        reg [2*WIDTH-1:0] sum_temp,a_temp,b_temp;
        always@(*)begin
	
        a_temp = {{{B_INT_W+1}{1'b0}},a[WIDTH-2:0],{{A_INT_W}{1'b0}}};
        b_temp = {{{A_INT_W+1}{1'b0}},b[WIDTH-2:0],{{B_INT_W}{1'b0}}};
        case({a[WIDTH-1],b[WIDTH-1]})
        2'b00:begin     //SGN = 0
            sum_temp = a_temp + b_temp;
            sum = {1'b0,sum_temp};
        end
        2'b01:begin     //SGN = 1
            if (a_temp>=b_temp) begin
                sum_temp = a_temp - b_temp;
                sum = {1'b0 , sum_temp};
            end
            else begin
                sum_temp = b_temp - a_temp;
                sum = {1'b1 , sum_temp };
            end
        end
        2'b10:begin //SGN !=1,2;
		if(b_temp >= a_temp)begin
		  sum_temp = b_temp - a_temp;
		  sum = {1'b0,sum_temp};
		end
		else begin
		  sum_temp = a_temp - b_temp;
		  sum = {1'b1,sum_temp};
		end
	end


        2'b11:begin
		sum_temp = a_temp + b_temp;
	    	if((a_temp=={{2*WIDTH}{1'b0}}) && (b_temp=={{2*WIDTH}{1'b0}}))begin
		sum = {{2*WIDTH+1}{1'b0}};
	    	end
	    	else begin
            	sum = {1'b1,sum_temp};
	    	end
        	end

        endcase
  
	 
    end 
  end

endcase
endgenerate
 




endmodule
