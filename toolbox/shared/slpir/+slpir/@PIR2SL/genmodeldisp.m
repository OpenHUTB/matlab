function genmodeldisp(~,msg,~,~)

    if isa(msg,'message')
        msg=msg.getString;
    end

    disp(['### ',msg]);

end