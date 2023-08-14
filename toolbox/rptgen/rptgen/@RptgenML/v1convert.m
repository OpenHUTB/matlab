function cv2=v1convert(cv1)










    mlock;

    if isa(cv1,'rptcomponent')||...
        isa(cv1,'rptcp')||...
        isstruct(cv1)
        cv2=convertComponent(cv1);

    elseif ischar(cv1)



        oldWarn=warning('off','MATLAB:unknownElementsNowStruc');





        cv1=rptgen.findFile(cv1);
        cv1=hgload(cv1);
        warning(oldWarn);

        cv2=RptgenML.v1convert(cv1);
    elseif ishghandle(cv1,'figure')


        cv2=convertUimenu(get(cv1,'children'));
    else
        error(message('rptgen:RptgenML_v1convert:invalidArgError'));
    end


    function cv2=convertComponent(cv1)




        v1name=cv1.comp.Class;
        v2name=get_v2_name(v1name);

        cv2=[];
        if~isempty(v2name)
            try
                cv2=feval(v2name);
                cv2.v1convert(cv1);
            catch ME
                warning(message('rptgen:RptgenML_v1convert:conversionError',ME.message));
            end
        end

        if isempty(cv2)
            warning(message('rptgen:RptgenML_v1convert:conversionError',v1name));
            cv2=RptgenML.cv1_adapter(cv1);
        end


        function cv2=convertUimenu(h)

            cv2=convertComponent(get(h,'UserData'));

            hChildren=get(h,'Children');
            for i=1:length(hChildren)
                childComp=convertUimenu(hChildren(i));
                if~isempty(childComp)&&isa(childComp,'rptgen.rptcomponent')
                    connect(cv2,childComp,'down');
                end
            end


            function v2name=get_v2_name(v1name)

                if~mlreportgen.re.internal.tools.LegacyConversion.isInitialized()
                    showLibrary(RptgenML.Root);
                end

                v2name=mlreportgen.re.internal.tools.LegacyConversion.get(v1name);

