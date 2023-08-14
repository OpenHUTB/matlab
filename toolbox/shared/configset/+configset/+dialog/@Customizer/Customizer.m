classdef Customizer<handle




    methods(Static)


        function addCustomization(fcn,varargin)
            if nargin==1
                loc_dispatcher('add',fcn);
            else
                loc_dispatcher('add',fcn,varargin{1});
            end
        end


        function clearCustomization()
            loc_dispatcher('clear');
        end


        function fcn=getCustomizationFunction()
            fcn=loc_dispatcher('get');
        end


        function out=getCustomizationResults(dlg)
            out=loc_dispatcher('apply',dlg);
        end


        function out=getCustomizationXML()
            out=loc_dispatcher('getXML');
        end
    end
end

function out=loc_dispatcher(name,varargin)

    mlock;
    persistent fcn;
    persistent xml;
    if isempty(fcn)
        fcn={};
    end
    if isempty(xml)
        xml={};
    end

    switch name
    case 'add'
        f=varargin{1};
        if isa(f,'function_handle')

            if nargin==3
                cm=varargin{2};


                mcs=configset.internal.getConfigSetStaticData;
                comps=mcs.ComponentList;
                for i=1:length(comps)
                    comp=comps{i};
                    cls=comp.Class;
                    if~strcmp(cls,'Simulink.ConfigSet')
                        cm.addDlgPreOpenFcn(cls,f);
                    end
                end
            end
            fcn{end+1}=f;
        elseif ischar(f)

            if~isempty(f)
                fid=fopen(f);
                if fid~=-1
                    xml{end+1}=fscanf(fid,'%c');
                    fclose(fid);
                end
            end
        end

    case 'clear'



        fcn={};
        xml={};
    case 'get'

        out=fcn;
    case 'apply'

        dlg=ConfigSet.DDGWrapper(varargin{1});
        dlg.batchMode=true;
        for i=1:length(fcn)
            f=fcn{i};
            f(dlg);
        end
        out=dlg.customized;


        out.custom=xml;
    case 'getXML'

        out=xml;
    end

end
