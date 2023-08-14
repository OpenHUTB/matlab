classdef SLHelper
    methods(Static)
        function r=isMLFB(h)


            try
                sfId=sfprivate('block2chart',h);
                r=sfId>0;
            catch
                r=false;
            end
        end




        function chart=getChart(mlfb)
            sfId=sfprivate('block2chart',mlfb);
            chart=idToHandle(sfroot,sfId);
        end

        function copyChartAndInterfaceObjectsProperties(origChart,singleChart)
            copyChartProperties(origChart,singleChart);
            [origOutputObjects,origInputObjects]=getPrototypeObjects(origChart);
            [singleOutputObjects,singleInputObjects]=getPrototypeObjects(singleChart);

            for ii=1:numel(origOutputObjects)
                copyObjectProperties(origOutputObjects{ii},singleOutputObjects{ii});
            end

            for jj=1:numel(origInputObjects)
                copyObjectProperties(origInputObjects{jj},singleInputObjects{jj});
            end


            function[outputObjects,inputObjects]=getPrototypeObjects(chart)
                Outputs=chart.Outputs;
                outputObjects=cell(1,numel(Outputs));
                for mm=1:numel(Outputs)
                    outputObjects{mm}=Outputs(mm);
                end

                objectMap=containers.Map();
                Inputs=chart.Inputs;
                for nn=1:numel(Inputs)
                    inp=Inputs(nn);
                    inpName=inp.Name;
                    if numel(inpName)>63
                        inpName=inpName(1:63);
                    end
                    objectMap(inpName)=inp;
                end

                Params=sf('find',sf('DataOf',chart.id),'.scope','PARAMETER');
                for oo=1:numel(Params)
                    parId=Params(oo);
                    par=idToHandle(slroot,parId);
                    parName=par.Name;
                    if numel(parName)>63
                        parName=parName(1:63);
                    end
                    objectMap(parName)=par;
                end

                inputObjects={};

                tr=mtree(chart.Script);
                if~isempty(tr)
                    fcn=tr.root;
                    if strcmp(fcn.kind,'FUNCTION')
                        ins=fcn.Ins;

                        inputObjects=cell(1,count(ins.List));
                        idx=1;

                        while~isempty(ins)
                            inpName=string(ins);
                            inputObjects{idx}=objectMap(inpName);
                            ins=ins.Next;
                            idx=idx+1;
                        end
                    end
                end
            end

            function copyObjectProperties(origIO,singleIO)
                try

                    singleIO.Scope=origIO.Scope;
                    singleIO.Port=origIO.Port;


                    singleIO.Complexity=origIO.Complexity;
                    singleIO.Props.Array.Size=origIO.Props.Array.Size;
                    singleIO.Props.Array.IsDynamic=origIO.Props.Array.IsDynamic;
                    singleIO.Props.Range.Minimum=origIO.Props.Range.Minimum;
                    singleIO.Props.Range.Maximum=origIO.Props.Range.Maximum;

                    singleIO.Props.Unit.Name=origIO.Props.Unit.Name;


                    singleIO.SaveToWorkspace=origIO.SaveToWorkspace;
                    singleIO.Description=origIO.Description;
                    singleIO.Document=origIO.Document;


                    singleIO.Tunable=origIO.Tunable;
                catch
                end
            end

            function copyChartProperties(origChart,singleChart)
                singleChart.ChartUpdate=origChart.ChartUpdate;
                singleChart.SampleTime=origChart.SampleTime;

                singleChart.SupportVariableSizing=origChart.SupportVariableSizing;
                singleChart.AllowDirectFeedthrough=origChart.AllowDirectFeedthrough;
                singleChart.SaturateOnIntegerOverflow=origChart.SaturateOnIntegerOverflow;

                singleChart.TreatAsFi=origChart.TreatAsFi;
                singleChart.InputFimath=origChart.InputFimath;
                singleChart.EmlDefaultFimath=origChart.EmlDefaultFimath;

                singleChart.Description=origChart.Description;
                singleChart.Document=origChart.Document;
            end
        end
    end
end

