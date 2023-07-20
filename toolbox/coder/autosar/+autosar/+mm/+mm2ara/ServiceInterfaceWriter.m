classdef ServiceInterfaceWriter<autosar.mm.mm2ara.ARAWriter










    properties(GetAccess='public',SetAccess='private')
        ARAGenerator;
        DDSDynamicEventFileName;
        DDSDynamicMethodFileName;
    end

    methods(Access=public)

        function this=ServiceInterfaceWriter(ServiceInterfaceBuilder,schemaVer)
            this=this@autosar.mm.mm2ara.ARAWriter(ServiceInterfaceBuilder,schemaVer);
        end

        function write(this)





            vals=this.ARABuilder.InterfaceQNameToM3iInt.values;
            perVals=this.ARABuilder.PerInterfaceQNameToM3iInt.values;
            if exist(this.AraFileLocation,'dir')==7
                rmdir(this.AraFileLocation,'s')
            end
            mkdir(this.AraFileLocation);
            for ii=1:numel(vals)
                [nsStr,~]=autosar.mm.mm2ara.NamespaceHelper.getNamespacesFor(...
                vals{ii}.Interface,namespaceSeparator='/');
                if exist(fullfile(this.AraFileLocation,nsStr),'dir')~=7
                    mkdir(this.AraFileLocation,nsStr);
                end
            end
            if~isempty(perVals)

                perDirectory=fullfile(this.AraFileLocation,'ara','per');
                try
                    if exist(perDirectory,'dir')==7
                        rmdir(perDirectory,'s')
                    end
                    mkdir(perDirectory);
                catch ME
                    rethrow(ME)
                end



                filePath=fullfile(perDirectory,'key_value_storage.h');
                codeWriter=rtw.connectivity.CodeWriter.create('callCBeautifier',...
                true,'filename',filePath,'append',true);
                this.writeFileDescription(codeWriter,'ara::per');


                autosar.mm.mm2ara.per.ARAPerKVSClassWriter(codeWriter,perVals,this.SchemaVersion,this.ARABuilder.getModelName())
            end
            uniqIntfNames=containers.Map;
            for ii=1:numel(vals)
                [nsStr,nsCellArray]=...
                autosar.mm.mm2ara.NamespaceHelper.getNamespacesFor(...
                vals{ii}.Interface,namespaceSeparator='/');
                shortName=vals{ii}.Interface.Name;




                this.DDSDynamicEventFileName=[shortName,'_araDynamicEventDDS.h'];
                this.DDSDynamicMethodFileName=[shortName,'_araDynamicMethodDDS.h'];
                if~uniqIntfNames.isKey(shortName)
                    uniqIntfNames(shortName)=true;

                    filePath=fullfile(this.AraFileLocation,this.DDSDynamicEventFileName);
                    codeWriter=rtw.connectivity.CodeWriter.create('callCBeautifier',...
                    true,'filename',filePath,'append',true);
                    codeWriter.wLine(['#ifndef ',shortName,'_ARA_COM_DDS_DYNAMIC_EVENT_WRAPPER_H']);
                    codeWriter.wLine(['#define ',shortName,'_ARA_COM_DDS_DYNAMIC_EVENT_WRAPPER_H']);


                    if slfeature('ARAComMiddleware')==3&&autosar.mm.mm2ara.ServiceInterfaceWriter.containsEvents(vals)
                        codeWriter.wLine('#include "AdaptiveAUTOSARDDSIdl.h"');
                        codeWriter.wLine('#include "AdaptiveAUTOSARDDSIdlPubSubTypes.h"');
                    end
                    codeWriter.close();


                    filePath=fullfile(this.AraFileLocation,this.DDSDynamicMethodFileName);
                    codeWriter=rtw.connectivity.CodeWriter.create('callCBeautifier',...
                    true,'filename',filePath,'append',true);
                    codeWriter.wLine(['#ifndef ',shortName,'_ARA_COM_DDS_DYNAMIC_METHOD_WRAPPER_H']);
                    codeWriter.wLine(['#define ',shortName,'_ARA_COM_DDS_DYNAMIC_METHOD_WRAPPER_H']);
                    codeWriter.close();
                end


                file_name_proxy=[lower(shortName),'_proxy.h'];
                file_name_skeleton=[lower(shortName),'_skeleton.h'];
                file_name_common=[lower(shortName),'_common.h'];

                if~isempty(vals{ii}.ProxyEvents)||...
                    ~isempty(vals{ii}.ProxyMethods)
                    filePath=fullfile(this.AraFileLocation,nsStr,file_name_proxy);
                    this.writeProxyHeader(filePath,vals{ii}.Interface,...
                    vals{ii}.ProxyEvents,vals{ii}.ProxyMethods,...
                    nsCellArray);
                end
                if~isempty(vals{ii}.SkeletonEvents)||...
                    ~isempty(vals{ii}.SkeletonMethods)
                    filePath=fullfile(this.AraFileLocation,nsStr,file_name_skeleton);
                    this.writeSkeletonHeader(filePath,vals{ii}.Interface,...
                    vals{ii}.SkeletonEvents,vals{ii}.SkeletonMethods,...
                    nsCellArray);
                    if~isempty(vals{ii}.SkeletonMethods)
                        file_name_skeleton_impl=[lower(shortName),'_skeleton_impl.h'];
                        filePath=fullfile(this.ARABuilder.getModelBuildDir(),...
                        file_name_skeleton_impl);
                        this.writeSkeletonImplHeader(filePath,vals{ii}.Interface,...
                        vals{ii}.SkeletonMethods,nsCellArray,nsStr,...
                        file_name_skeleton);
                    end
                end

                filePath=fullfile(this.AraFileLocation,nsStr,file_name_common);
                this.writeCommonHeader(filePath,vals{ii},nsCellArray);
            end



            keys=uniqIntfNames.keys;
            for ii=1:numel(keys)
                filePath=fullfile(this.AraFileLocation,[keys{ii},'_araDynamicEventDDS.h']);
                codeWriter=rtw.connectivity.CodeWriter.create('callCBeautifier',...
                false,'filename',filePath,'append',true);
                codeWriter.wLine(['#endif //',shortName,'_ARA_COM_DDS_DYNAMIC_EVENT_WRAPPER_H']);
                codeWriter.close();

                filePath=fullfile(this.AraFileLocation,[keys{ii},'_araDynamicMethodDDS.h']);
                codeWriter=rtw.connectivity.CodeWriter.create('callCBeautifier',...
                true,'filename',filePath,'append',true);
                codeWriter.wLine(['#endif //',shortName,'_ARA_COM_DDS_DYNAMIC_METHOD_WRAPPER_H']);
                codeWriter.close();
            end


            toolchain=get_param(this.ARABuilder.getModelName(),'Toolchain');
            if strcmp(toolchain,'AUTOSAR Adaptive Linux Executable')
                if autosar.mm.mm2ara.ServiceInterfaceWriter.isValidForFastrtps(this.AraFileLocation,vals)

                    if~isempty(which('linux.internal.createDDSBindingFilesFromIDL'))
                        idlFileName=fullfile(this.AraFileLocation,'AdaptiveAUTOSARDDSIdl.idl');
                        serializationFiles=linux.internal.createDDSBindingFilesFromIDL(idlFileName);
                        this.WrittenFiles=[this.WrittenFiles,serializationFiles];
                    else

                        error(message('MATLAB:hwstubs:general:spkgNotInstalled',...
                        'Embedded Coder Support Package For Linux Applications',...
                        'ECLINUX'));
                    end
                end
            end
        end

        function writeProxyHeader(this,filePath,m3iInf,proxyEventList,...
            proxyMethodList,nsCellArray)

            this.WrittenFiles=[this.WrittenFiles,filePath];
            codeWriter=rtw.connectivity.CodeWriter.create('callCBeautifier',...
            true,'filename',filePath,'append',false);
            this.writeFileDescription(codeWriter,'ara::com');
            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#ifndef ',...
            [upper(m3iInf.Name),'_PROXY_H_']);
            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#define ',...
            [upper(m3iInf.Name),'_PROXY_H_']);
            proxyClassName=[m3iInf.Name,'Proxy'];
            codeWriter.wLine('#include <memory>');
            codeWriter.wLine('#include <utility>');
            codeWriter.wLine('#include "ara/core/vector.h"');
            codeWriter.wLine(['#include "',lower(m3iInf.Name),'_common.h"']);

            autosar.mm.mm2ara.NamespaceHelper.writeBegNamespaces(codeWriter,nsCellArray);
            codeWriter.wBlockStart('namespace proxy');


            autosar.mm.mm2ara.com.ARAComProxyClassWriter(codeWriter,...
            m3iInf,proxyClassName,proxyEventList,proxyMethodList,...
            fullfile(this.AraFileLocation,this.DDSDynamicEventFileName),...
            fullfile(this.AraFileLocation,'AdaptiveAUTOSARDDSIdl.idl'),...
            fullfile(this.AraFileLocation,this.DDSDynamicMethodFileName),...
            this.ARABuilder.getModelName(),this.SchemaVersion);

            codeWriter.wBlockEnd('namespace proxy');
            autosar.mm.mm2ara.NamespaceHelper.writeEndNamespaces(codeWriter,nsCellArray);
            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#endif // #ifndef ',...
            [upper(m3iInf.Name),'_PROXY_H_']);
            codeWriter.close();
        end

        function writeSkeletonHeader(this,filePath,m3iInf,skeletonEventList,...
            skeletonMethodList,nsCellArray)

            shortName=m3iInf.Name;
            skeletonClassName=[shortName,'Skeleton'];
            this.WrittenFiles=[this.WrittenFiles,filePath];
            codeWriter=rtw.connectivity.CodeWriter.create('callCBeautifier',...
            true,'filename',filePath,'append',false);
            this.writeFileDescription(codeWriter,'ara::com');
            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#ifndef ',...
            [upper(shortName),'_SKELETON_H_']);
            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#define ',...
            [upper(shortName),'_SKELETON_H_']);
            codeWriter.wLine('#include <memory>');
            codeWriter.wLine(['#include "',lower(shortName),'_common.h"']);
            autosar.mm.mm2ara.NamespaceHelper.writeBegNamespaces(codeWriter,nsCellArray);
            codeWriter.wBlockStart('namespace skeleton ');


            autosar.mm.mm2ara.com.ARAComSkeletonClassWriter(codeWriter,...
            m3iInf,skeletonClassName,skeletonEventList,...
            skeletonMethodList,fullfile(this.AraFileLocation,this.DDSDynamicEventFileName),...
            fullfile(this.AraFileLocation,'AdaptiveAUTOSARDDSIdl.idl'),...
            fullfile(this.AraFileLocation,this.DDSDynamicMethodFileName),...
            this.ARABuilder.getModelName(),this.SchemaVersion);

            codeWriter.wBlockEnd('namespace skeleton');
            autosar.mm.mm2ara.NamespaceHelper.writeEndNamespaces(codeWriter,nsCellArray);
            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#endif  //#ifndef ',...
            [upper(shortName),'_SKELETON_H_']);
            codeWriter.close();
        end

        function writeSkeletonImplHeader(this,filePath,m3iInf,...
            skeletonMethodList,nsCellArray,nsStr,file_name_skeleton)

            shortName=m3iInf.Name;
            skeletonClassName=[shortName,'Skeleton'];
            this.WrittenFiles=[this.WrittenFiles,filePath];
            codeWriter=rtw.connectivity.CodeWriter.create('callCBeautifier',...
            true,'filename',filePath,'append',false);


            schemaString=strrep(erase(this.SchemaVersion,'ARA_VER_'),'_','-');
            comments=sprintf(...
            ['This file contains ara::com <interface>SkeletonImpl class.\n\n',...
            'Code generated for Simulink Adaptive model: "%s"',...
            '\nAUTOSAR AP Release: "%s"\nOn: "%s" '],...
            this.ARABuilder.getComponentName(),schemaString,datestr(clock));
            codeWriter.wComment(comments);

            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#ifndef ',...
            [upper(shortName),'_SKELETON_IMPL_H_']);
            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#define ',...
            [upper(shortName),'_SKELETON_IMPL_H_']);
            codeWriter.wLine('#include <memory>');
            codeWriter.wLine('#include <functional>');

            if isempty(nsStr)
                skelHeaderFile=file_name_skeleton;
            else
                skelHeaderFile=[nsStr,'/',file_name_skeleton];
            end

            codeWriter.wLine(['#include "',skelHeaderFile,'"']);
            autosar.mm.mm2ara.NamespaceHelper.writeBegNamespaces(codeWriter,nsCellArray);
            codeWriter.wBlockStart('namespace skeleton ');

            autosar.mm.mm2ara.com.ARAComSkeletonImplClassWriter(codeWriter,...
            skeletonClassName,skeletonMethodList);

            codeWriter.wBlockEnd('namespace skeleton');
            autosar.mm.mm2ara.NamespaceHelper.writeEndNamespaces(codeWriter,nsCellArray);
            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#endif  //#ifndef ',...
            [upper(shortName),'_SKELETON_IMPL_H_']);
            codeWriter.close();
        end

        function writeCommonHeader(this,filePath,val,nsCellArray)

            m3iInf=val.Interface;
            shortName=m3iInf.Name;
            this.WrittenFiles=[this.WrittenFiles,filePath];
            codeWriter=rtw.connectivity.CodeWriter.create('callCBeautifier',...
            true,'filename',filePath,'append',false);
            this.writeFileDescription(codeWriter,'ara::com');
            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#ifndef ',...
            [upper(shortName),'_COMMON_H_']);
            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#define ',...
            [upper(shortName),'_COMMON_H_']);
            this.writeCommonIncludeHeaders(m3iInf,codeWriter);

            codeWriter.wLine('#include "ara/core/array.h"');
            codeWriter.wLine('#include "ara/core/vector.h"');
            codeWriter.wLine('#include "ara/core/future.h"');
            codeWriter.wLine('#include "ara/core/promise.h"');
            codeWriter.wLine('#include "ara/com/types.h"');
            codeWriter.wLine('#include "MiddlewareFactories.h"');
            codeWriter.wLine('#include <fastrtps/types/DynamicData.h>');
            codeWriter.wLine('#include <fastrtps/types/DynamicPubSubType.h>');
            codeWriter.wLine('#include <fastrtps/types/DynamicTypeBuilderFactory.h>');
            codeWriter.wLine('#include <fastrtps/types/DynamicDataFactory.h>');
            codeWriter.wLine('#include <fastrtps/types/DynamicTypeBuilderPtr.h>');
            codeWriter.wLine('#include <fastrtps/types/TypeIdentifier.h>');
            codeWriter.wLine('#include "DDSEndianHelper.h"');
            codeWriter.wLine('#include "DDSSerializer.h"');



            if slfeature('ARAComMiddleWare')==3&&autosar.mm.mm2ara.ServiceInterfaceWriter.containsEvents({val})
                codeWriter.wLine('#include "AdaptiveAUTOSARDDSIdl.h"');
                codeWriter.wLine('#include "AdaptiveAUTOSARDDSIdlPubSubTypes.h"');
            end
            codeWriter.wLine(['#include "',this.DDSDynamicEventFileName,'"']);
            codeWriter.wLine(['#include "',this.DDSDynamicMethodFileName,'"']);

            codeWriter.wLine('#endif');
            codeWriter.close();
        end
    end

    methods(Static,Access=private)

        function contains=containsEvents(vals)
            contains=false;
            for ii=1:numel(vals)
                if~isempty(vals{ii}.ProxyEvents)||~isempty(vals{ii}.SkeletonEvents)
                    contains=true;
                    return;
                end
            end
        end

        function isValid=isValidForFastrtps(araFileLocation,vals)
            isValid=true;
            if slfeature('ARAComMiddleWare')~=3
                isValid=false;
                return;
            end

            if~isfile(fullfile(araFileLocation,'AdaptiveAUTOSARDDSIdl.idl'))||~autosar.mm.mm2ara.ServiceInterfaceWriter.containsEvents(vals)
                isValid=false;
                return;
            end
        end

        function writeCommonIncludeHeaders(m3iInf,codeWriter)

            if isa(m3iInf,'Simulink.metamodel.arplatform.interface.ServiceInterface')
                uniqueTypes=containers.Map;


                for kk=1:m3iInf.Events.size
                    m3iEvnt=m3iInf.Events.at(kk);


                    if~isempty(m3iEvnt.Type)&&...
                        ~any(strcmp(autosarcore.mm.sl2mm.SwBaseTypeBuilder.getAdaptivePlatformTypes(),m3iEvnt.Type.Name))
                        typeName=lower(m3iEvnt.Type.Name);
                        nsStr=autosar.mm.mm2ara.NamespaceHelper.getNamespacesFor(m3iEvnt.Type,namespaceSeparator='/');
                        uniqueTypes(typeName)=[nsStr,'impl_type_',typeName,'.h'];
                    end
                end


                for kk=1:m3iInf.Methods.size()
                    curMthd=m3iInf.Methods.at(kk);
                    for ll=1:curMthd.Arguments.size()
                        curMthdArg=curMthd.Arguments.at(ll);


                        if~isempty(curMthdArg.Type)&&...
                            ~any(strcmp(autosarcore.mm.sl2mm.SwBaseTypeBuilder.getAdaptivePlatformTypes(),curMthdArg.Type.Name))
                            typeName=lower(curMthdArg.Type.Name);
                            nsStr=autosar.mm.mm2ara.NamespaceHelper.getNamespacesFor(curMthdArg.Type,namespaceSeparator='/');
                            uniqueTypes(typeName)=[nsStr,'impl_type_',typeName,'.h'];
                        end
                    end
                end

                vals=uniqueTypes.values;
                for kk=1:numel(vals)
                    codeWriter.wLine(['#include "',vals{kk},'"']);
                end
            end
        end

        function writeHeaderInclusionGuard(codeWriter,nsCellArray,prependStr,appendStr)

            str=prependStr;
            for ii=1:numel(nsCellArray)
                str=[str,upper(nsCellArray{ii})];%#ok<AGROW>
                str=[str,'_'];%#ok<AGROW>
            end
            str=[str,appendStr];
            codeWriter.wLine(str);
        end
    end
end





