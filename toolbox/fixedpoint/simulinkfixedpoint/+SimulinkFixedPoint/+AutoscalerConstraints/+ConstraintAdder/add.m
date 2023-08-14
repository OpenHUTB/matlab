function constraint=add(constraint1,constraint2)







    adder=getAdder(SimulinkFixedPoint.AutoscalerConstraints.ConstraintAdder.Factory,constraint1,constraint2);


    constraint=addConstraints(adder,constraint1,constraint2);
end


