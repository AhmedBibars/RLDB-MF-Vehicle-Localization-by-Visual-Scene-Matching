function [DiffVector]=LDBMatch(LDBVector,LDBDatabase)
Temp=repmat(LDBVector,size(LDBDatabase,1),1);
Temp=bitxor(Temp,LDBDatabase);
DiffVector=sum(Temp,2);