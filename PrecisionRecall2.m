function [Recall,Precision]=PrecisionRecall2(CorrectLocalization,MatchDiffVector) 
RTMatchingNum=size(CorrectLocalization,1); %RT video frames number 

Recall=zeros(100,1);
Precision=zeros(100,1);

IterationStep=(max(MatchDiffVector)-min(MatchDiffVector))/100;
for i=1:101
    AcceptanceLevel=min(MatchDiffVector)+(i-1)*IterationStep;
    AcceptedPoints=MatchDiffVector<=AcceptanceLevel;
    Recall(i,1)=100*sum(AcceptedPoints)/RTMatchingNum;
    Precision(i,1)=sum(bitand(AcceptedPoints,CorrectLocalization))/sum(AcceptedPoints);
end
