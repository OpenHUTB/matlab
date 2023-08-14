



classdef Net<handle&dnnfpga.dagCompile.AddData&matlab.mixin.Copyable
    properties
        name='';
driver
        receivers=dnnfpga.dagCompile.PortInst.empty;
size
dataFormat
        ngraph=dnnfpga.dagCompile.NGraph.empty;
        id=uint32(0);
    end
    methods
        function obj=Net(driver)
            import dnnfpga.dagCompile.*
            obj.driver=driver;
            obj.name=driver.nameFull;
            driver.net=obj;
            obj.dataFormat=DataFormat.None;
        end
        function obj=addPortInst(obj,pinst)
            obj.receivers=[pinst,obj.receivers];
            pinst.net=obj;
        end
        function replacePortInst(obj,pinst,pinstToBeReplaced)
            if obj.driver==pinstToBeReplaced
                obj.driver=pinst;
            end
            receivers=[];
            for i=1:numel(obj.receivers)
                receiver=obj.receivers(i);
                if receiver==pinstToBeReplaced
                    receivers=[receivers,pinst];
                else
                    receivers=[receivers,receiver];
                end
            end
            obj.receivers=receivers;
        end
        function removePortInst(obj,pinst)
            if obj.driver==pinst
                obj.driver=[];
            end
            receivers=[];
            for i=1:numel(obj.receivers)
                receiver=obj.receivers(i);
                if receiver~=pinst
                    receivers=[receivers,receiver];
                end
            end
            obj.receivers=receivers;
        end

        function insert(obj,component)
            if numel(obj.driver)==1&&numel(obj.receivers)>=1

                driver=obj.driver;
                obj.ngraph.removeNet(obj);
                obj.replacePortInst(component.outputs(),obj.driver);
                obj.driver.net=obj;
                obj.name=obj.driver.nameFull;
                obj.ngraph.addNet(obj);

                netAdded=dnnfpga.dagCompile.Net(driver);
                netAdded.size=obj.size;
                netAdded.receivers=component.inputs';
                component.inputs.net=netAdded;
                component.inputs.size=obj.size;
                component.outputs.size=obj.size;
                obj.ngraph.addComponent(component);
                obj.ngraph.addNet(netAdded);
            end
        end
    end
    methods

        function toDot(obj,fid,addLabel,addSizes)

            if nargin<3
                addLabel=false;
            end

            if nargin<4
                addSizes=false;
            end

            driver=obj.driver;
            src=driver.component;
            srcName=src.getDotSrc();
            first=true;
            for i=1:numel(obj.receivers)
                pinst=obj.receivers(i);
                dst=pinst.component;
                dstName=dst.getDotDst();
                if first&&addSizes
                    sizeStr='';
                    if~isempty(src.outputs)
                        sizeStr=num2str(src.outputs.size);
                    end
                    sizeStr=sprintf('[%s]',sizeStr);
                    if~addLabel
                        fprintf(fid,"%s -> %s [taillabel = %s ]\n",srcName,dstName,['" ',sizeStr,' "']);
                    else
                        fprintf(fid,"%s -> %s [headlabel = %s taillabel = %s ]\n",srcName,dstName,['" ',int2str(obj.id),' "'],['" ',sizeStr,' "']);
                    end
                else
                    if~addLabel
                        fprintf(fid,"%s -> %s\n",srcName,dstName);
                    else
                        fprintf(fid,"%s -> %s [headlabel = %s ]\n",srcName,dstName,['" ',int2str(obj.id),' "']);
                    end
                end
                first=false;
            end
        end

        function disp(obj)
            obj.display();
        end
        function display(obj)
            if numel(obj)==1
                one=obj(1);
                fprintf('%s\n',one.toString());
            else
                fprintf('[');
                for i=1:numel(obj)
                    one=obj(i);
                    fprintf('%s ',one.toString());
                end
                fprintf(']\n');
            end
        end
        function str=toString(obj)
            import dnnfpga.dagCompile.*
            sizeStr='';
            formatStr='';
            if~isempty(obj.size)
                sizeStr=num2str(obj.size);
            end
            if obj.dataFormat~=DataFormat.None
                formatStr=sprintf("(%s)",obj.dataFormat);
            end
            str=sprintf('<Net [%s] %s %s>',sizeStr,formatStr,obj.name);
        end
    end
    methods(Access=protected)

        function cp=copyElement(obj)
            cp=copyElement@matlab.mixin.Copyable(obj);
            if~isempty(obj.receivers)
                cp.receivers=copy(obj.receivers);
            end
            if~isempty(obj.driver)
                cp.driver=copy(obj.driver);
            end
        end
    end
end
