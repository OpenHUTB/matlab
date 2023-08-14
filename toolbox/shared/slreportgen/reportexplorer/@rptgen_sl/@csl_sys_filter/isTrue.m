function tf=isTrue(this,sys)






    if(nargin<2)
        sys=get(rptgen_sl.appdata_sl,'CurrentSystem');
    end

    if isempty(sys)
        tf=false;
        this.status('No system found for filter',2);

    elseif(locNumBlocks(sys)<this.minNumBlocks)
        tf=false;

    elseif(locNumSubSys(sys)<this.minNumSubSystems)
        tf=false;

    else
        tf=locMaskTest(this.isMask,sys)&&locPassesCustomFilter(this,sys);
    end


    function nb=locNumBlocks(sys)

        try
            nb=length(get_param(sys,'Blocks'));
        catch ex %#ok<NASGU>
            nb=0;
        end


        function ns=locNumSubSys(sys)



            try
                subsys=rptgen_sl.rgFindBlocks(sys,1,{'BlockType','\<SubSystem\>'});
            catch ex %#ok<NASGU>
                subsys={};
            end
            sys=strrep(sys,char(10),' ');
            ns=length(subsys)-length(find(strcmp(subsys,sys)));


            function tf=locMaskTest(isMask,sys)

                if strcmp(isMask,'either')
                    tf=true;
                else
                    try
                        slType=get_param(sys,'type');
                    catch ex %#ok<NASGU>

                        tf=false;
                        return;
                    end

                    if strcmp(slType,'block_diagram')
                        hasMask=false;

                    else
                        try
                            hasMask=strcmp(get_param(sys,'Mask'),'on');
                        catch ex %#ok<NASGU>
                            hasMask='no';
                        end
                    end

                    if strcmp(isMask,'no');
                        tf=~hasMask;
                    else
                        tf=hasMask;
                    end
                end


                function tf=locPassesCustomFilter(this,currentSystem)%#ok<INUSD>

                    isFiltered=false;

                    if(~isempty(this.customFilterCode))

                        eval(this.customFilterCode);

                    end

                    tf=~isFiltered;
