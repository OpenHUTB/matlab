function hf=updateSectionInfo(this,hf,hC,arith)






    if isFilterSOS(hf)
        if~strcmpi(arith,'double')
            bfp=hC.SimulinkHandle;
            block=get_param(bfp,'Object');

            switch block.stageIOMode
            case 'Same as input'
                [insize,inbp]=hdlgetsizesfromtype(hf.inputsltype);
                if isFilterdf1SOSonly(hf)
                    numstatesize=insize;
                    numstatebp=inbp;
                    denstatesize=insize;
                    denstatebp=inbp;
                else
                    sectioninsize=insize;
                    sectioninbp=inbp;
                    sectionoutsize=insize;
                    sectionoutbp=inbp;
                end

            case{'Binary point scaling'}
                if isFilterdf1SOSonly(hf)
                    numstatesize=this.hdlslResolve('stageIOWordLength',bfp);
                    numstatebp=this.hdlslResolve('stageInFracLength',bfp);
                    denstatesize=numstatesize;
                    denstatebp=this.hdlslResolve('stageOutFracLength',bfp);
                else
                    sectioninsize=this.hdlslResolve('stageIOWordLength',bfp);
                    sectioninbp=this.hdlslResolve('stageInFracLength',bfp);
                    sectionoutsize=sectioninsize;
                    sectionoutbp=this.hdlslResolve('stageOutFracLength',bfp);
                end

            case{'Slope and bias scaling'}

                error(message('hdlcoder:validate:unsupportedslopebias'));

            otherwise
                error(message('hdlcoder:validate:InvalidOutputMode',block.outputMode,block.Name));
            end


            if isFilterdf1SOSonly(hf)
                [~,hf.numstatesltype]=hdlgettypesfromsizes(numstatesize,numstatebp,true);
                [~,hf.denstatesltype]=hdlgettypesfromsizes(denstatesize,denstatebp,true);
            else
                [~,hf.sectioninputsltype]=hdlgettypesfromsizes(sectioninsize,sectioninbp,true);
                [~,hf.sectionoutputsltype]=hdlgettypesfromsizes(sectionoutsize,sectionoutbp,true);
            end
        else
            if isFilterdf1SOSonly(hf)
                hf.numstatesltype=hf.inputsltype;
                hf.denstatesltype=hf.inputsltype;
            else
                hf.sectioninputsltype=hf.inputsltype;
                hf.sectionoutputsltype=hf.inputsltype;
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


