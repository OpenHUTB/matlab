function az=automlMotoLngaz(Ffwext_z,Flfext_z,Fmext_z,Fraext_z,Frwext_z,Fufext_z,Fzext,Fzf,Fzr,adf,amu,amur,g,lf,lm,lr,mfw,mlf,mm,mra,mrw,muf,pCGxm,pCGzm,pCGxlf,pCGxra,pCGzlf,pCGzra,pCGxuf,pCGzuf,pdf,pmu,pmur,rdf,rmu,rmur)

%#codegen
    coder.allowpcode('plain')







    t2=cos(pmu);
    t3=cos(pmur);
    t4=sin(pmu);
    t5=sin(pmur);
    t6=rmu.^2;
    t7=rmur.^2;
    et1=Ffwext_z+Flfext_z+Fmext_z+Fraext_z+Frwext_z+Fufext_z+Fzext+Fzf+Fzr+g.*mfw+g.*mlf+g.*mm+g.*mra+g.*mrw+g.*muf+amur.*lr.*mfw.*t3+amur.*lr.*mlf.*t3+amur.*lr.*mm.*t3+amur.*lr.*muf.*t3+amur.*mra.*pCGxra.*t3+amur.*mra.*pCGzra.*t5-adf.*mfw.*t2.*t3+adf.*mfw.*t4.*t5-adf.*mlf.*t2.*t3+adf.*mlf.*t4.*t5-lr.*mfw.*t5.*t7-lr.*mlf.*t5.*t7-lr.*mm.*t5.*t7-lr.*muf.*t5.*t7-mra.*pCGxra.*t5.*t7+mra.*pCGzra.*t3.*t7+amu.*lf.*mfw.*t2.*t3-amu.*lf.*mfw.*t4.*t5+amur.*lf.*mfw.*t2.*t3-amur.*lf.*mfw.*t4.*t5+amu.*lm.*mfw.*t2.*t3-amu.*lm.*mfw.*t4.*t5+amur.*lm.*mfw.*t2.*t3-amur.*lm.*mfw.*t4.*t5+amu.*lm.*mlf.*t2.*t3-amu.*lm.*mlf.*t4.*t5+amur.*lm.*mlf.*t2.*t3;
    et2=-amur.*lm.*mlf.*t4.*t5+amu.*lm.*muf.*t2.*t3-amu.*lm.*muf.*t4.*t5+amur.*lm.*muf.*t2.*t3-amur.*lm.*muf.*t4.*t5+amu.*mlf.*pCGxlf.*t2.*t3-amu.*mlf.*pCGxlf.*t4.*t5+amu.*mlf.*pCGzlf.*t2.*t5+amu.*mlf.*pCGzlf.*t3.*t4+amur.*mlf.*pCGxlf.*t2.*t3-amur.*mlf.*pCGxlf.*t4.*t5+amur.*mlf.*pCGzlf.*t2.*t5+amur.*mlf.*pCGzlf.*t3.*t4+amu.*mm.*pCGxm.*t2.*t3-amu.*mm.*pCGxm.*t4.*t5+amu.*mm.*pCGzm.*t2.*t5+amu.*mm.*pCGzm.*t3.*t4+amur.*mm.*pCGxm.*t2.*t3-amur.*mm.*pCGxm.*t4.*t5+amur.*mm.*pCGzm.*t2.*t5+amur.*mm.*pCGzm.*t3.*t4+amu.*muf.*pCGxuf.*t2.*t3-amu.*muf.*pCGxuf.*t4.*t5+amu.*muf.*pCGzuf.*t2.*t5+amu.*muf.*pCGzuf.*t3.*t4+amur.*muf.*pCGxuf.*t2.*t3-amur.*muf.*pCGxuf.*t4.*t5+amur.*muf.*pCGzuf.*t2.*t5+amur.*muf.*pCGzuf.*t3.*t4+amu.*mfw.*pdf.*t2.*t5;
    et3=amu.*mfw.*pdf.*t3.*t4+amur.*mfw.*pdf.*t2.*t5+amur.*mfw.*pdf.*t3.*t4+amu.*mlf.*pdf.*t2.*t5+amu.*mlf.*pdf.*t3.*t4+amur.*mlf.*pdf.*t2.*t5+amur.*mlf.*pdf.*t3.*t4-lf.*mfw.*t2.*t5.*t6-lf.*mfw.*t3.*t4.*t6-lf.*mfw.*t2.*t5.*t7-lf.*mfw.*t3.*t4.*t7-lm.*mfw.*t2.*t5.*t6-lm.*mfw.*t3.*t4.*t6-lm.*mfw.*t2.*t5.*t7-lm.*mfw.*t3.*t4.*t7-lm.*mlf.*t2.*t5.*t6-lm.*mlf.*t3.*t4.*t6-lm.*mlf.*t2.*t5.*t7-lm.*mlf.*t3.*t4.*t7-lm.*muf.*t2.*t5.*t6-lm.*muf.*t3.*t4.*t6-lm.*muf.*t2.*t5.*t7-lm.*muf.*t3.*t4.*t7-mlf.*pCGxlf.*t2.*t5.*t6-mlf.*pCGxlf.*t3.*t4.*t6+mlf.*pCGzlf.*t2.*t3.*t6-mlf.*pCGxlf.*t2.*t5.*t7;
    et4=-mlf.*pCGxlf.*t3.*t4.*t7+mlf.*pCGzlf.*t2.*t3.*t7-mlf.*pCGzlf.*t4.*t5.*t6-mlf.*pCGzlf.*t4.*t5.*t7-mm.*pCGxm.*t2.*t5.*t6-mm.*pCGxm.*t3.*t4.*t6+mm.*pCGzm.*t2.*t3.*t6-mm.*pCGxm.*t2.*t5.*t7-mm.*pCGxm.*t3.*t4.*t7+mm.*pCGzm.*t2.*t3.*t7-mm.*pCGzm.*t4.*t5.*t6-mm.*pCGzm.*t4.*t5.*t7-muf.*pCGxuf.*t2.*t5.*t6-muf.*pCGxuf.*t3.*t4.*t6+muf.*pCGzuf.*t2.*t3.*t6-muf.*pCGxuf.*t2.*t5.*t7-muf.*pCGxuf.*t3.*t4.*t7+muf.*pCGzuf.*t2.*t3.*t7-muf.*pCGzuf.*t4.*t5.*t6-muf.*pCGzuf.*t4.*t5.*t7+mfw.*pdf.*t2.*t3.*t6+mfw.*pdf.*t2.*t3.*t7-mfw.*pdf.*t4.*t5.*t6-mfw.*pdf.*t4.*t5.*t7+mlf.*pdf.*t2.*t3.*t6+mlf.*pdf.*t2.*t3.*t7-mlf.*pdf.*t4.*t5.*t6;
    et5=-mlf.*pdf.*t4.*t5.*t7+mfw.*rdf.*rmu.*t2.*t5.*2.0+mfw.*rdf.*rmu.*t3.*t4.*2.0+mfw.*rdf.*rmur.*t2.*t5.*2.0+mfw.*rdf.*rmur.*t3.*t4.*2.0+mlf.*rdf.*rmu.*t2.*t5.*2.0+mlf.*rdf.*rmu.*t3.*t4.*2.0+mlf.*rdf.*rmur.*t2.*t5.*2.0+mlf.*rdf.*rmur.*t3.*t4.*2.0-lf.*mfw.*rmu.*rmur.*t2.*t5.*2.0-lf.*mfw.*rmu.*rmur.*t3.*t4.*2.0-lm.*mfw.*rmu.*rmur.*t2.*t5.*2.0-lm.*mfw.*rmu.*rmur.*t3.*t4.*2.0-lm.*mlf.*rmu.*rmur.*t2.*t5.*2.0-lm.*mlf.*rmu.*rmur.*t3.*t4.*2.0-lm.*muf.*rmu.*rmur.*t2.*t5.*2.0-lm.*muf.*rmu.*rmur.*t3.*t4.*2.0-mlf.*pCGxlf.*rmu.*rmur.*t2.*t5.*2.0-mlf.*pCGxlf.*rmu.*rmur.*t3.*t4.*2.0+mlf.*pCGzlf.*rmu.*rmur.*t2.*t3.*2.0-mlf.*pCGzlf.*rmu.*rmur.*t4.*t5.*2.0-mm.*pCGxm.*rmu.*rmur.*t2.*t5.*2.0-mm.*pCGxm.*rmu.*rmur.*t3.*t4.*2.0+mm.*pCGzm.*rmu.*rmur.*t2.*t3.*2.0;
    et6=mm.*pCGzm.*rmu.*rmur.*t4.*t5.*-2.0-muf.*pCGxuf.*rmu.*rmur.*t2.*t5.*2.0-muf.*pCGxuf.*rmu.*rmur.*t3.*t4.*2.0+muf.*pCGzuf.*rmu.*rmur.*t2.*t3.*2.0-muf.*pCGzuf.*rmu.*rmur.*t4.*t5.*2.0+mfw.*pdf.*rmu.*rmur.*t2.*t3.*2.0-mfw.*pdf.*rmu.*rmur.*t4.*t5.*2.0+mlf.*pdf.*rmu.*rmur.*t2.*t3.*2.0-mlf.*pdf.*rmu.*rmur.*t4.*t5.*2.0;
    az=(et1+et2+et3+et4+et5+et6)./(mfw+mlf+mm+mra+mrw+muf);


end
