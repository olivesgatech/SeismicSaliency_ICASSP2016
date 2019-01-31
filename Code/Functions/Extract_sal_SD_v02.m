function [ Salt_Dome_RGC ] = Extract_sal_SD_v02( close_oper, Dil_oper, Sal_OP, capture_SP )
if capture_SP
    [Salt_Dome_RG, ~] = RegionGrowing_mod(Sal_OP,1);  
else
    % Seed_pt = [379, 342];
    Seed_pt = [97, 161];
    [Salt_Dome_RG, ~] = RegionGrowing_mod(Sal_OP,1,Seed_pt);   
end

Salt_Dome_RGC = imclose(Salt_Dome_RG, strel('disk',close_oper));  
Salt_Dome_RGC = imdilate(Salt_Dome_RGC, strel('disk',Dil_oper));  

end

