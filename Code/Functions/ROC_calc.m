function [ True_Pos, False_Pos, True_Neg, False_Neg ] = ROC_calc( Sal_OP, Ground_Truth  )

    True_Pos    = 0;    
    False_Pos   = 0;   
    True_Neg    = 0;   
    False_Neg   = 0;   

    for ximg = 1:size(Sal_OP,1)
        for yimg = 1:size(Sal_OP,2)

            % Check True Positives
            if(Ground_Truth(ximg,yimg)==true && Sal_OP(ximg,yimg)==true)
                True_Pos = True_Pos + 1;
            end
            % Check False Positives
            if(Ground_Truth(ximg,yimg)==false && Sal_OP(ximg,yimg)==true )
                False_Pos = False_Pos + 1;
            end
            % Check True Negatives
            if(Ground_Truth(ximg,yimg)==false && Sal_OP(ximg,yimg)==false)
                True_Neg = True_Neg + 1;
            end
            % Check False Negatives
            if(Ground_Truth(ximg,yimg)==true && Sal_OP(ximg,yimg)==false)
                False_Neg = False_Neg + 1;
            end

        end
    end
   
end

