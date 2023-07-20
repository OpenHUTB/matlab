function[preflector,treflector]=getReflectorMesh(obj,isProbeFeed)

    reflectorShape=obj.Substrate.Shape;
    switch reflectorShape
    case 'box'
        L=obj.GroundPlaneLength;
        W=obj.GroundPlaneWidth;
        N=10;
        gatingCondition=(~isequal(L,0))&&(~isequal(W,0));
        if gatingCondition
            base=em.internal.makeplate(L,W,N,'chebyshev-II');
        end
    case 'cylinder'
        R=obj.GroundPlaneRadius;
        gatingCondition=~isequal(R,0);
        if gatingCondition
            base=em.internal.makecircle(R);
        end
        L=R;
        W=R;
    end

    if gatingCondition
        if~isProbeFeed

            domains={base};
            if isDielectricSubstrate(obj)
                if isHminUserSpecified(obj)
                    minel=getMinContourEdgeLength(obj);
                else
                    minel=0.3*getMeshEdgeLength(obj);
                end
                [preflector,treflector]=meshGroundPlane(obj,domains,0,[],L,W,0,minel);
                setMeshMinContourEdgeLength(obj,minel);
            else
                [preflector,treflector]=meshGroundPlane(obj,domains,0,[],L,W,0);
            end
            if~isinfGP(obj)&&~isDielectricSubstrate(obj)
                [preflector,treflector]=remeshReflector(obj,preflector,treflector);
            end
        else
            Wfeed=getFeedWidth(obj.Exciter);
            feedpoint=getFeedPoint(obj);
            [preflector,treflector]=meshGroundPlane(obj,Wfeed,1,feedpoint);
            [preflector,treflector]=remeshReflector(obj,preflector,treflector);
        end
    else
        preflector=[];
        treflector=[];
    end

    function[preflector,treflector]=remeshReflector(obj,preflector,treflector)

        mesherType=getMesherType(obj);
        if mesherType
            T=[];
            EpsilonR=[];
            LossTangent=[];
            meshReflector=em.internal.makeMeshStructure(preflector,treflector,...
            T,EpsilonR,LossTangent);
            Hmax=getMeshEdgeLength(obj);
            Hmin=getMinContourEdgeLength(obj);
            if isempty(Hmin)&&~isa(obj.Exciter,'em.ConeAntenna')
                Hmin=0.75*Hmax;
            end

            mR=remesh(obj,meshReflector,Hmin,Hmax);
            preflector=mR.Points;
            treflector=mR.Triangles;
        end
    end
end