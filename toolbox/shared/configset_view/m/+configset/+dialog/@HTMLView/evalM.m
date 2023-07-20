function out=evalM(obj,data)




    try
        out=eval(data.mscript);
        json=jsonencode(out);


        data.success=true;
        data.ret=json;

    catch ME

        data.success=false;
        data.ret=ME.message;

    end

    obj.publish('evalM',data);

