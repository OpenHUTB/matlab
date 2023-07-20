





function checks=largeBitWidthChecks(this,hC)%#ok<INUSL>



    checks=[];

    if(isempty(hC.PirOutputSignals))
        return;
    end

    function flag=checkTypeWidth(Osignal)
        flag=false;

        if(isempty(regexp(class(Osignal),'^hdlcoder')))
            return
        end

        outType=Osignal.Type;


        if(outType.isWordType)
            flag=(outType.WordLength>128);
        end

        return;
    end

    flagged=arrayfun(@checkTypeWidth,hC.PirOutputSignals);

    if(any(flagged))
        checks.path=getfullname(hC.SimulinkHandle);
        checks.type='block';
        checks.message=message('hdlcoder:makehdl:BitWidthTooLarge',hC.Name).getString();
        checks.level='Warning';
        checks.MessageID='hdlcoder:makehdl:BitWidthTooLarge';
    end
    return;
end
