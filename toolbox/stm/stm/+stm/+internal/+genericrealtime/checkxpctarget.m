function out=checkxpctarget()


    if(exist('slrealtime.Target','class')~=8)
        out=false;
    else

        [~,out]=evalc('license(''checkout'', ''xpc_target'')');
    end
end
