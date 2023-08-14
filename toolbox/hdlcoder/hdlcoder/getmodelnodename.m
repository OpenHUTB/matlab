function[snn,dutname]=getmodelnodename(curmodel,snn,checkVSS)






    if nargin<3




        checkVSS=true;
    end


    dutname=removemodelname(snn,curmodel);
    startnode=dutname;

    if(~isempty(startnode))

        regexp_snn=hdlsearchnodename(startnode);





        regexp_snn=regexprep(regexp_snn,'\\/\\/','\/');
        ss_list=find_system(curmodel,'regexp','on','SearchDepth',1,'Name',['^',regexp_snn,'$'],...
        'BlockType','SubSystem');
        mr_list=find_system(curmodel,'regexp','on','SearchDepth',1,'Name',['^',regexp_snn,'$'],...
        'BlockType','ModelReference');
        snn_list=[ss_list,mr_list];

        if(isempty(snn_list))

            try


                deepdut=find_system(snn,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SubSystem');
                if isempty(deepdut)
                    deepdut=find_system(snn,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','ModelReference');
                    if isempty(deepdut)

                        error(message('hdlcoder:makehdl:systemnotfound',snn,curmodel));
                    end
                end
            catch me

                error(message('hdlcoder:makehdl:systemnotfound',snn,curmodel));
            end
            dutname=get_param(deepdut,'Name');
            if iscell(dutname)
                dutname=dutname{1};
            end
        elseif(numel(snn_list)==1)
            snn=snn_list{1};
        else


            snn_list=find_system(curmodel,'SearchDepth',1,'Name',dutname,...
            'BlockType','SubSystem');
            if(numel(snn_list)==1)
                snn=snn_list{1};
            else
                error(message('hdlcoder:makehdl:toomanymatches',snn,curmodel));
            end
        end

        if strcmp(get_param(snn,'BlockType'),'SubSystem')&&...
            strcmpi(get_param(snn,'Variant'),'on')&&...
checkVSS
            error(message('hdlcoder:makehdl:variantsubsystemasdut',snn,curmodel));
        end
    end

    function snn=removemodelname(snn,curmodel)


        if strcmp(snn,curmodel)
            snn='';
        else

            modelname=[curmodel,'/'];
            len_snn=length(snn);
            len_modelname=length(modelname);
            if(len_snn>len_modelname)

                if(strcmp(modelname,snn(1:len_modelname)))

                    snn=snn(len_modelname+1:end);
                end
            end
        end



