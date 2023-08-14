function result=hdlisvectorport(parsed_dims,port)







    if(parsed_dims(1,port)==1&&parsed_dims(2,port)==1)||...
        (parsed_dims(1,port)==2&&parsed_dims(2,port)==1&&parsed_dims(3,port)==1)
        result=false;
    else
        result=true;
    end




