function dpigenerator_disp(msg)


    if isa(msg,'message')
        msg=msg.getString;
    end
    fprintf('### %s\n',msg);
