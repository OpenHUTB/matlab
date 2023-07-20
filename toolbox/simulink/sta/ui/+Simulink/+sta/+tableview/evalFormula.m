function evalFormula(appInstanceID,payLoad)





    newstr=strrep(payLoad.expression,'=','');

    payLoadOut.isError=false;
    try

        result=eval(newstr);

    catch
        result=payLoad.expression;
        payLoadOut.isError=true;
    end



    payLoadOut.result=result;

    payLoadOut.columnVal=payLoad.columnVal;
    payLoadOut.datastoreidx=payLoad.datastoreidx;
    fullChannel=sprintf('/sta%s/%s',appInstanceID,'tableview/evalUpdate');
    message.publish(fullChannel,payLoadOut);


end

