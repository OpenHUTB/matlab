classdef AddComponentInfo<handle










    properties
    end

    methods(Static)
        function str=encode(varargin)
            str='';

            ip=inputParser();
            ip.addParameter('SID','',@ischar);
            ip.addParameter('FunctionName','',@ischar);
            ip.addParameter('LineNumber','',@isnumeric);
            ip.parse(varargin{:});

            in=ip.Results;

            if~isempty(in.SID)



                str=[str,'$sid$',strrep(in.SID,'$','$$')];
            end

            if~isempty(in.FunctionName)

                str=[str,'$fct$',in.FunctionName];
            end

            if~isempty(in.LineNumber)
                str=[str,'$ln$',num2str(in.LineNumber)];
            end
        end

        function out=decode(str)
            out=struct('SID','','FunctionName','',...
            'LineNumber',[]);

            sid=slmetric.util.AddComponentInfo.getToken('$sid$',str);
            out.SID=strrep(sid,'$$','$');

            out.FunctionName=...
            slmetric.util.AddComponentInfo.getToken('$fct$',str);

            ln=slmetric.util.AddComponentInfo.getToken('$ln$',str);

            if~isempty(ln)
                out.LineNumber=str2double(ln);
            end
        end

        function h=getHyperlink(componentPath,str)
            info=slmetric.util.AddComponentInfo.decode(str);

            if~isempty(info.SID)
                h=['matlab: Simulink.ID.hilite(''',...
                info.SID,''')'];

            else
                h=['matlab: Simulink.ID.hilite(''',...
                Simulink.ID.getSID(componentPath),''')'];
            end
        end
    end

    methods(Access=private,Static)
        function val=getToken(token,str)
            val='';

            tokenPos=strfind(str,token);

            if~isempty(tokenPos)

                val=str(tokenPos+length(token):end);


                nextTokenPos=regexp(val,'\$(fct|ln|sid)\$','once','start');

                if~isempty(nextTokenPos)
                    val=val(1:nextTokenPos-1);
                end
            end
        end
    end
end

