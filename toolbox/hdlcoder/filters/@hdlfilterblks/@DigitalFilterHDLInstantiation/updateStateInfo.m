function hf=updateStateInfo(this,hf,hC,arith)






    if isFilterFIRt(hf)||isFilterSOS(hf)&&~isFilterdf1SOSonly(hf)


        if~strcmpi(arith,'double')
            bfp=hC.SimulinkHandle;
            block=get_param(bfp,'Object');

            switch block.memoryMode
            case 'Same as input'

                [insize,inbp]=hdlgetsizesfromtype(hf.inputsltype);
                statesize=insize;

                statebp=inbp;

            case 'Same as accumulator'
                if isFilterSOS(hf)
                    [accumsize,accumbp]=hdlgetsizesfromtype(hf.numaccumsltype);
                    statesize=accumsize;
                    statebp=accumbp;
                else
                    [accumsize,accumbp]=hdlgetsizesfromtype(hf.accumsltype);
                    statesize=accumsize;
                    statebp=accumbp;
                end

            case{'Binary point scaling'}
                statesize=this.hdlslResolve('MemoryWordLength',bfp);
                statebp=this.hdlslResolve('MemoryFracLength',bfp);

            case{'Slope and bias scaling'}

                error(message('hdlcoder:validate:unsupportedslopebias'));

            otherwise
                error(message('hdlcoder:validate:InvalidStateMode',block.memoryMode,block.Name));
            end

            [~,statesltype]=hdlgettypesfromsizes(statesize,statebp,true);
            if isFilterdf1tSOS(hf)
                [hf.numstatesltype,hf.denstatesltype]=deal(statesltype);
            else
                hf.statesltype=statesltype;
            end
        else
            if isFilterdf1tSOS(hf)
                [hf.numstatesltype,hf.denstatesltype]=deal(hf.inputsltype);
            else
                hf.statesltype=hf.inputsltype;
            end
        end
    end

    function isSOS=isFilterSOS(hf)
        isSOS=(isa(hf,'hdlfilter.df1sos')||...
        isa(hf,'hdlfilter.df1tsos')||...
        isa(hf,'hdlfilter.df2sos')||...
        isa(hf,'hdlfilter.df2tsos'));


        function isdf1SOSonly=isFilterdf1SOSonly(hf)

            isdf1SOSonly=strcmpi(class(hf),'hdlfilter.df1sos');


            function isdf1tSOS=isFilterdf1tSOS(hf)
                isdf1tSOS=isa(hf,'hdlfilter.df1tsos');



                function isFIRt=isFilterFIRt(hf)
                    isFIRt=isa(hf,'hdlfilter.dffirt');

