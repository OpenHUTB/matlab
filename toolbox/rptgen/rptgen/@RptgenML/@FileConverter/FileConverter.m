function obj=FileConverter(varargin)








    if rem(length(varargin),2)==1
        rgRoot=varargin{1};
        varargin=varargin(2:end);
        obj=find(rgRoot,'-depth',1,'-isa',mfilename('class'));
        if~isempty(obj)
            obj=obj(1);
        else
            obj=feval(mfilename('class'));
            if isempty(down(rgRoot))
                connect(obj,rgRoot,'up');
            else
                connect(obj,down(rgRoot),'right');
            end
        end


        if isempty(obj.SrcFileName)
            try

                xmlExt=char(getExtension(com.mathworks.toolbox.rptgencore.output.OutputFormat.getFormat('db')));
            catch
                xmlExt='xml';
            end

            pwdXmlFiles=dir(['*.',xmlExt]);

            if~isempty(pwdXmlFiles)
                fileDate=zeros(1,length(pwdXmlFiles));
                for i=length(pwdXmlFiles):-1:1
                    if strcmpi(pwdXmlFiles(i).name,'rptstylesheets.xml')||...
                        strcmpi(pwdXmlFiles(i).name,'rptcomps2.xml')||...
                        strcmpi(pwdXmlFiles(i).name,'rptcomps.xml')||...
                        strcmpi(pwdXmlFiles(i).name,'demos.xml')||...
                        strcmpi(pwdXmlFiles(i).name,'info.xml')
                        fileDate(i)=0;
                        pwdXmlFiles(i).name='';
                    else
                        fileDate(i)=pwdXmlFiles(i).datenum;
                    end
                end
                [lastDate,dateIndex]=max(fileDate);
                currFile=fullfile(pwd,pwdXmlFiles(dateIndex).name);
                obj.SrcFileName=currFile;
            end
        end

        set(obj,varargin{:});

        if~isempty(rgRoot.Editor)
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('HierarchyChangedEvent',rgRoot);
            rgRoot.Editor.view(obj);
        end
    else
        obj=feval(mfilename('class'));
        set(obj,varargin{:});
    end