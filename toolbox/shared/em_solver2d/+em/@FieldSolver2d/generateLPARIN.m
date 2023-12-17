function generateLPARIN(obj,mesh,dir)

    if nargin==2
        dir=pwd;
    end
    filename=fullfile(dir,'linpar.lparin');

    nl=obj.numLayer;
    ys=obj.yCoordSub;
    tai=obj.idxTraceAtInterface;
    s=obj.separationTraceAtInterface;

    epsilonR=[obj.epsilonRSub,1.0];
    lossTangent=[obj.lossTangentSub,0.0];

    fileID=fopen(filename,'w');
    fprintf(fileID,'%d\n',mesh.Node.numNode);
    fprintf(fileID,'%d\n',sum(obj.numTrace));

    for iLayer=1:nl
        for iTrace=1:obj.numTrace(iLayer)
            if obj.thickTrace{iLayer}(iTrace)>0
                fprintf(fileID,'%d\n',2*(mesh.Pulse.widthTrace{iLayer}(iTrace)+mesh.Pulse.thickTrace{iLayer}(iTrace)));
            else
                fprintf(fileID,'%d\n',mesh.Pulse.widthTrace{iLayer}(iTrace));
            end
        end
    end

    if obj.codeSub<=0
        ngp=mesh.Pulse.groundplane;
    else
        ngp=mesh.Pulse.groundplane+mesh.Pulse.excessLeftWidthSub(obj.numSub+1);
        if obj.codeSub==2
            ngp=ngp+2*sum(mesh.Pulse.thickSub);
        end
    end
    fprintf(fileID,'%d\n',ngp);

    ndt=0;
    for iSub=2:obj.numSub

        if abs(epsilonR(iSub)-epsilonR(iSub-1))>eps||abs(lossTangent(iSub)-lossTangent(iSub-1))>eps
            if~isempty(find(abs(obj.yCoordTrace{iSub}-ys(iSub))<eps,1))
                ndt=ndt+sum(mesh.Pulse.separationTrace{iSub})+mesh.Pulse.excessLeftWidthSub(iSub)+mesh.Pulse.excessRightWidthSub(iSub);
            else
                ndt=ndt+mesh.Pulse.excessLeftWidthSub(iSub);
            end
        end
    end

    if obj.hasTraceOnTopLayer&&(abs(epsilonR(obj.numSub)-1)>eps||abs(lossTangent(obj.numSub))>eps)
        ndt=ndt+sum(mesh.Pulse.separationTrace{nl})+mesh.Pulse.excessLeftWidthSub(nl)+mesh.Pulse.excessRightWidthSub(nl);


    elseif obj.codeSub==0&&~obj.hasTraceOnTopLayer&&...
        (abs(epsilonR(obj.numSub)-1)>eps||abs(lossTangent(obj.numSub))>eps)
        ndt=ndt+mesh.Pulse.excessLeftWidthSub(obj.numSub+1);
    end
    if obj.codeSub~=2
        for iSub=1:obj.numSub
            if epsilonR(iSub)~=1||lossTangent(iSub)~=0
                ndt=ndt+2*mesh.Pulse.thickSub(iSub);
            end
        end
    end
    fprintf(fileID,'%d\n',ndt);



    formatSpec='  %.15e  %.15e\n';
    for iLayer=1:nl
        for iTrace=1:obj.numTrace(iLayer)
            x0=obj.xCoordTrace{iLayer}(iTrace)+0.5*obj.widthTrace{iLayer}(iTrace);
            numPulse=mesh.Pulse.widthTrace{iLayer}(iTrace);
            ds=pi/numPulse;
            for k=0:numPulse
                alpha=-0.5*pi+ds*k;
                fprintf(fileID,formatSpec,...
                x0+0.5*obj.widthTrace{iLayer}(iTrace)*sin(alpha),...
                obj.yCoordTrace{iLayer}(iTrace));
            end

            if obj.thickTrace{iLayer}(iTrace)>0
                for k=0:numPulse
                    alpha=-0.5*pi+ds*k;
                    fprintf(fileID,formatSpec,...
                    x0+0.5*obj.widthTrace{iLayer}(iTrace)*sin(alpha),...
                    obj.yCoordTrace{iLayer}(iTrace)+obj.thickTrace{iLayer}(iTrace));
                end
                y0=obj.yCoordTrace{iLayer}(iTrace);
                numPulse=mesh.Pulse.thickTrace{iLayer}(iTrace);
                ds=pi/numPulse;
                for k=0:numPulse
                    alpha=-0.5*pi+ds*k;
                    fprintf(fileID,formatSpec,...
                    x0-0.5*obj.widthTrace{iLayer}(iTrace),...
                    y0+0.5*obj.thickTrace{iLayer}(iTrace)*(1+sin(alpha)));
                end
                for k=0:numPulse
                    alpha=-0.5*pi+ds*k;
                    fprintf(fileID,formatSpec,...
                    x0+0.5*obj.widthTrace{iLayer}(iTrace),...
                    y0+0.5*obj.thickTrace{iLayer}(iTrace)*(1+sin(alpha)));
                end
            end

        end
    end


    numPulse=mesh.Pulse.groundplane;
    ds=mesh.GP.width/numPulse;
    for k=0:numPulse
        fprintf(fileID,formatSpec,...
        mesh.GP.coordCorner(1,1)+k*ds,0.0000);
    end
    if obj.codeSub>0
        numPulse=mesh.Pulse.excessLeftWidthSub(obj.numSub+1);
        ds=mesh.GP.width/numPulse;
        for k=0:numPulse
            fprintf(fileID,formatSpec,...
            mesh.GP.coordCorner(1,1)+k*ds,ys(obj.numSub+1));
        end
    end


    for iSub=1:obj.numSub
        if epsilonR(iSub)~=1||lossTangent(iSub)~=0||obj.codeSub==2
            numPulse=mesh.Pulse.thickSub(iSub);
            ds=obj.thickSub(iSub)/numPulse;
            for k=0:numPulse
                fprintf(fileID,formatSpec,...
                mesh.GP.coordCorner(1,1),ys(iSub)+k*ds);
            end
            for k=0:numPulse
                fprintf(fileID,formatSpec,...
                mesh.GP.coordCorner(1,2),ys(iSub)+k*ds);
            end
        end
    end


    for iLayer=2:nl
        if abs(epsilonR(iLayer)-epsilonR(iLayer-1))>eps||abs(lossTangent(iLayer)-lossTangent(iLayer-1))>eps
            if length(tai{iLayer})>1
                for iSep=1:length(tai{iLayer})-1
                    idx=tai{iLayer}(iSep);
                    x0=obj.xCoordTrace{iLayer}(idx)+obj.widthTrace{iLayer}(idx)+0.5*s{iLayer}(iSep);
                    numPulse=mesh.Pulse.separationTrace{iLayer}(iSep);
                    ds=pi/numPulse;
                    for k=0:numPulse
                        alpha=-0.5*pi+ds*k;
                        fprintf(fileID,formatSpec,...
                        x0+0.5*s{iLayer}(iSep)*sin(alpha),ys(iLayer));
                    end
                end
            end

            if~isempty(tai{iLayer})
                numPulse=mesh.Pulse.excessLeftWidthSub(iLayer);
                ds=0.5*pi/numPulse;
                x0=mesh.GP.coordCorner(1,1);
                idx=tai{iLayer}(1);
                for k=0:numPulse
                    alpha=ds*k;
                    fprintf(fileID,formatSpec,...
                    x0+(obj.xCoordTrace{iLayer}(idx)-mesh.GP.coordCorner(1,1))*sin(alpha),ys(iLayer));
                end
                numPulse=mesh.Pulse.excessRightWidthSub(iLayer);
                ds=0.5*pi/numPulse;
                x0=mesh.GP.coordCorner(1,2);
                idx=tai{iLayer}(end);
                for k=0:numPulse
                    alpha=-0.5*pi+ds*k;
                    fprintf(fileID,formatSpec,...
                    x0+(mesh.GP.coordCorner(1,2)-(obj.xCoordTrace{iLayer}(idx)+obj.widthTrace{iLayer}(idx)))*sin(alpha),ys(iLayer));
                end
            else
                numPulse=mesh.Pulse.excessLeftWidthSub(iLayer);
                ds=mesh.GP.width/numPulse;
                for k=0:numPulse
                    fprintf(fileID,formatSpec,...
                    mesh.GP.coordCorner(1,1)+k*ds,ys(iLayer));
                end
            end
        end
    end













    if obj.codeSub==0&&~obj.hasTraceOnTopLayer&&...
        (abs(epsilonR(obj.numSub)-1)>eps||abs(lossTangent(obj.numSub))>eps)
        numPulse=mesh.Pulse.excessLeftWidthSub(obj.numSub+1);
        ds=mesh.GP.width/numPulse;
        for k=0:numPulse
            fprintf(fileID,formatSpec,...
            mesh.GP.coordCorner(1,1)+k*ds,ys(obj.numSub+1));
        end
    end


    air=complex(1.0,0.0);
    l=1;
    formatSpec=' %d %d (%f,%.7e) (%f,%.7e)\n';

    for iLayer=1:nl
        for iTrace=1:obj.numTrace(iLayer)

            if abs(obj.yCoordTrace{iLayer}(iTrace)-ys(iLayer))<eps
                epsilonRRight=complex(epsilonR(iLayer-1),-lossTangent(iLayer-1)*epsilonR(iLayer-1));
            else
                epsilonRRight=complex(epsilonR(iLayer),-lossTangent(iLayer)*epsilonR(iLayer));
            end
            for k=1:mesh.Pulse.widthTrace{iLayer}(iTrace)
                fprintf(fileID,formatSpec,...
                l,l+1,real(epsilonRRight),imag(epsilonRRight),real(air),imag(air));
                l=l+1;
            end
            l=l+1;
            if obj.thickTrace{iLayer}(iTrace)>0

                epsilonRLeft=complex(epsilonR(iLayer),-lossTangent(iLayer)*epsilonR(iLayer));
                for k=1:mesh.Pulse.widthTrace{iLayer}(iTrace)
                    fprintf(fileID,formatSpec,...
                    l,l+1,real(air),imag(air),real(epsilonRLeft),imag(epsilonRLeft));
                    l=l+1;
                end
                l=l+1;

                for k=1:mesh.Pulse.thickTrace{iLayer}(iTrace)
                    fprintf(fileID,formatSpec,...
                    l,l+1,real(air),imag(air),real(epsilonRLeft),imag(epsilonRLeft));
                    l=l+1;
                end
                l=l+1;

                epsilonRRight=complex(epsilonR(iLayer),-lossTangent(iLayer)*epsilonR(iLayer));
                for k=1:mesh.Pulse.thickTrace{iLayer}(iTrace)
                    fprintf(fileID,formatSpec,...
                    l,l+1,real(epsilonRRight),imag(epsilonRRight),real(air),imag(air));
                    l=l+1;
                end
                l=l+1;
            end
        end
    end


    epsilonRLeft=complex(epsilonR(1),-lossTangent(1)*epsilonR(1));
    for k=1:mesh.Pulse.groundplane
        fprintf(fileID,formatSpec,...
        l,l+1,real(air),imag(air),real(epsilonRLeft),imag(epsilonRLeft));
        l=l+1;
    end
    l=l+1;

    if obj.codeSub>0
        epsilonRRight=complex(epsilonR(obj.numSub),-lossTangent(obj.numSub)*epsilonR(obj.numSub));
        for k=1:mesh.Pulse.excessLeftWidthSub(obj.numSub+1)
            fprintf(fileID,formatSpec,...
            l,l+1,real(epsilonRRight),imag(epsilonRRight),real(air),imag(air));
            l=l+1;
        end
        l=l+1;
    end


    for iSub=1:obj.numSub
        if epsilonR(iSub)~=1||lossTangent(iSub)~=0||obj.codeSub==2

            epsilonRRight=complex(epsilonR(iSub),-lossTangent(iSub)*epsilonR(iSub));
            for k=1:mesh.Pulse.thickSub(iSub)
                fprintf(fileID,formatSpec,...
                l,l+1,real(epsilonRRight),imag(epsilonRRight),real(air),imag(air));
                l=l+1;
            end
            l=l+1;

            epsilonRLeft=complex(epsilonR(iSub),-lossTangent(iSub)*epsilonR(iSub));
            for k=1:mesh.Pulse.thickSub(iSub)
                fprintf(fileID,formatSpec,...
                l,l+1,real(air),imag(air),real(epsilonRLeft),imag(epsilonRLeft));
                l=l+1;
            end
            l=l+1;
        end
    end


    for iLayer=2:nl
        if abs(epsilonR(iLayer)-epsilonR(iLayer-1))>eps||abs(lossTangent(iLayer)-lossTangent(iLayer-1))>eps
            epsilonRRight=complex(epsilonR(iLayer-1),-lossTangent(iLayer-1)*epsilonR(iLayer-1));
            epsilonRLeft=complex(epsilonR(iLayer),-lossTangent(iLayer)*epsilonR(iLayer));
            for iTrace=1:obj.numTrace(iLayer)-1
                for k=1:mesh.Pulse.separationTrace{iLayer}(iTrace)
                    fprintf(fileID,formatSpec,...
                    l,l+1,real(epsilonRRight),imag(epsilonRRight),real(epsilonRLeft),imag(epsilonRLeft));
                    l=l+1;
                end
                l=l+1;
            end
            for k=1:mesh.Pulse.excessLeftWidthSub(iLayer)
                fprintf(fileID,formatSpec,...
                l,l+1,real(epsilonRRight),imag(epsilonRRight),real(epsilonRLeft),imag(epsilonRLeft));
                l=l+1;
            end
            l=l+1;
            if obj.numTrace(iLayer)>0
                for k=1:mesh.Pulse.excessRightWidthSub(iLayer)
                    fprintf(fileID,formatSpec,...
                    l,l+1,real(epsilonRRight),imag(epsilonRRight),real(epsilonRLeft),imag(epsilonRLeft));
                    l=l+1;
                end
                l=l+1;
            end
        end
    end















    if obj.codeSub==0&&~obj.hasTraceOnTopLayer&&...
        (abs(epsilonR(obj.numSub)-1)>eps||abs(lossTangent(obj.numSub))>eps)
        for k=1:mesh.Pulse.excessLeftWidthSub(obj.numSub+1)
            fprintf(fileID,formatSpec,...
            l,l+1,real(epsilonRRight),imag(epsilonRRight),real(air),imag(air));
            l=l+1;
        end
    end


    fclose(fileID);

end

