DatabaseVideoPath='G:\Binary Surf Highway\Night.wmv';
QueryVideoPath='G:\Binary Surf Highway\Day.wmv';
Descriptor1=RLDB_Descriptor; % create object of the class
Descriptor1=Descriptor1.SelectRandomCellPairs_UD;  %randomly select cell-pairs
FrameCropStart=33;FrameCropEnd=172; %interest area in the frame (vertical limits).
load GroundTruth_Highway;  % groundtruth quary/database equivelant frames, to compare our results with it.
load('MapPoints_Highway.mat');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MatchPanoramicImageSequances_RLDB;

%%%%%%Precision-Recall%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;plot(Recall,Precision);
axis([0 100 0 100]);grid;
xlabel('Recall');ylabel('Precision');
title('Precision-Recall Curve, RLDB');
%%%Display Distance matrix.%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MaxV=max(max(DistanceMatrix));
MinV=min(min(DistanceMatrix));
DistanceMatrixDisplay=255*((DistanceMatrix-MinV)/(MaxV-MinV)); % put the values in the gray-scale range: [0,255]
DistanceMatrixDisplay=uint8(round(DistanceMatrixDisplay));
figure;imshow(DistanceMatrixDisplay);
title('Distance Matrix, Highway-RLDB');
%%%%Best Match%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;plot(GT(:,1));hold on;
plot(CurrentImage,'x');
xlabel('Quary frame number','FontSize', 20,'FontWeight','bold','Color','k');  % 'bold'/'normal'  'k'=black
ylabel('Database frame number','FontSize', 20,'FontWeight','bold','Color','k');
legend('Ground truth','Best match','Location','Best');save('CBD_SI_Result.mat','Result2D','CorrectLocalization','CurrentImage','Recall','Precision','LongestGap');

%save('Highway_SI_Result.mat','Result2D','CorrectLocalization','CurrentImage','Recall','Precision','LongestGap');