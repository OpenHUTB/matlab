classdef CandidateComponent<systemcomposer.xmi.CandidateElement
    properties
        Name="";
        ParentArchitecture;

        ReferenceArchExtElementID=""

        ReferenceArch=[];

        PortMapFromArchElementID=[];

        IsInliningItsArch=false;

        Valid=true;
        InvalidReason="";

        ZCHandle=[];
    end

    methods
        function this=CandidateComponent(name,parArch,extID,refCompID)
            this@systemcomposer.xmi.CandidateElement(extID);
            this.Name=name;
            this.ReferenceArchExtElementID=refCompID;
            this.ParentArchitecture=parArch;
        end

        function addConnector(this,refArchPort,conn)
            refArchPortID=refArchPort.ExtElementID;
            if isempty(this.PortMapFromArchElementID)
                this.PortMapFromArchElementID=containers.Map;
            end



            if~isKey(this.PortMapFromArchElementID,refArchPortID)
                thisPortInfo.RefArchPort=refArchPort;
                thisPortInfo.Connectors=conn;
                this.PortMapFromArchElementID(refArchPortID)=thisPortInfo;
            else
                thisPortInfo=this.PortMapFromArchElementID(refArchPortID);
                thisPortInfo.Connectors=[thisPortInfo.Connectors,conn];
                this.PortMapFromArchElementID(refArchPortID)=thisPortInfo;
            end
        end

        function fixFanInConnectors(this)
            if~isempty(this.PortMapFromArchElementID)
                pInfo=this.PortMapFromArchElementID.values;
                for k=1:length(pInfo)
                    thisInfo=pInfo{k};
                    if thisInfo.RefArchPort.ComputedDir=="in"&&...
                        length(thisInfo.Connectors)>1
                        conn=thisInfo.Connectors;
                        validConn=[];
                        for m=1:length(conn)
                            if conn(m).Valid&&~conn(m).Replaced
                                validConn=[validConn,conn(m)];%#ok
                            end
                        end


                        if length(validConn)>1

                            this.ParentArchitecture.addAdapter(...
                            validConn,this,thisInfo.RefArchPort);
                        end
                    end
                end
            end
        end

        function setInvalid(this,reason)
            this.Valid=false;
            this.InvalidReason=reason;
        end


        function print(this,printer)
            if this.Name==""
                cName="<None>";
            else
                cName=this.Name;
            end
            printer.print("Component: "+cName+...
            " [Valid = "+this.Valid+"] ["+...
            this.ReferenceArch.getPostLinkFullPath()+"]");
            if this.IsInliningItsArch
                printer.openScope("");
                printer.openScope("InlineArch: "+this.ReferenceArch.Name);
                this.ReferenceArch.print(printer);
                printer.closeScope("InlineArch: "+this.ReferenceArch.Name);
                printer.closeScope("");
            end
        end
    end
end
