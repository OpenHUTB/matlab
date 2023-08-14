function lat=extractCPLatency(cp_ir)



    lat=qoroptimizations.getCPIRNodeAccumulativeLatency(cp_ir.getCP(1).getNode(cp_ir.getCP(1).numNodes),cp_ir.getCP(1));
end