classdef PIRGraphBuilder<internal.ml2pir.PIRGraphBuilder




    methods(Access=protected)

        function traceCmtPrefix=createTraceCmtPrefix(this)


            sysNum=slprivate('getSystemNumber',this.PirOptions.OriginalSLHandle);

            if any(strcmp(get_param(this.PirOptions.OriginalSLHandle,'LinkStatus'),{'resolved','implicit'}))


                mlfbPath=get_param(this.PirOptions.OriginalSLHandle,'ReferenceBlock');
            else


                mlfbPath=Simulink.ID.getFullName(this.PirOptions.OriginalSLHandle);
            end
            rtObj=sfroot;
            emChart=rtObj.find('-isa','Stateflow.EMChart','Path',mlfbPath);
            chart=sf('get',emChart.Id,'.states');
            ssIdNum=sf('get',chart,'.ssIdNumber');

            traceCmtPrefix=strcat(strcat('<S',num2str(sysNum),'>'),':',num2str(ssIdNum),':');
        end

        function fullPath=getRootPath(this,~)




            parentNetwork=this.PirOptions.ParentNetwork;
            fullPath=parentNetwork.fullPath;
        end

    end
end

