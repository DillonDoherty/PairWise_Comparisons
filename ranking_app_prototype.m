function ranking_app_prototype
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function runs the app 
% prototype in Matlab.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%create the dataset of images and labels 
data_and_labels = choose_data_and_labels();

%run the selection section (construct the transition matrix)
[transition_matrix, path_indices] = select_preferences(data_and_labels);

%display the results of the selection process
calculate_and_display_results(transition_matrix, path_indices, data_and_labels);

end





function [files, paths] = paths_vector()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function creates a vector 
% of image paths from selected 
% images.
%
% Parameters: None
% 
% Output:
%    files: a vector containing 
%           image file names.
%    paths: a vector containing 
%           image paths.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%clear the console
clc

%prompt the user to select multiple images once or each image individually
choice = input('Select 1 to select all images at once. Select 2 to select them one at a time: ');

%check whether the user chose to select all images at once
if choice == 1
    
    %select the files and paths
    [filenames, pathname] = uigetfile('*.*',  'Pick an image files' ,'MultiSelect' ,'on');
    
    %set a variable for the number of image
    num_images = size(filenames, 2);
    
    %clear the console
    clc

    %initialize the output files vector
    files = strings(num_images, 1);

    %initialize the output paths vector
    paths = strings(num_images, 1);
    
    %select the images and store their file paths in the variable paths
    for i = 1:num_images

        %store filename in files
        files(i) = filenames(i);

        %store pathname in paths
        paths(i) = pathname;

    end
        
%individually select images
else

    %determine the number of images to select from user input
    num_images = input('How many images do you want to select? ');

    %clear the console
    clc

    %initialize the output files vector
    files = strings(num_images, 1);

    %initialize the output paths vector
    paths = strings(num_images, 1);

    %select the images and store their file paths in the variable paths
    for i = 1:num_images

        %select the image and store the path 
        [filename, pathname] = uigetfile('*.*', 'Pick an image file');

        %store filename in files
        files(i) = filename;

        %store pathname in paths
        paths(i) = pathname;

    end

end

end





function data_and_labels = choose_labels(files, paths)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function creates the mapping from paths 
% to labels with user input.
%
% Parameter: 
%     files: a vector of image file names.
%     paths: a vector of image paths.
%
% Output:
%     data_and_labels: a Map object mapping 
%                      image paths to labels.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%prompt user to input whether to create labels manually or automatically
choice = input('Select 1 to automatically label images. Select 2 to manually label them: ');

%initialize the Map object
data_and_labels = containers.Map;

%map each path in paths to a user inputted label
for i=1:size(paths, 1)
    
    %create the full filepath 
    filepath = char(paths(i) + files(i));
    
    %check which choice for label input the user selected
    if choice == 2
        
        %read in an image
        image = imread(filepath);
    
        %display image
        imshow(image);
        
        %clear the console
        clc
    
        %prompt the user to input a label for this image
        label = input('Input a label for the displayed image: ', 's');
        
        %close the figure
        close all
    
    %automatically label the paths if manual labeling is not chosen
    else
        
        %extract the label from filepath
        [~, label, ~] = fileparts(filepath);
              
    end
    
    %clear the console
    clc
    
    %add the path and label to 
    data_and_labels(filepath) = label;
    
end

end





function data_and_labels = choose_data_and_labels()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function prompts the user to select images 
% for the comparisons and type in corresponding 
% labels.
% 
% Parameters: None.
%
% Output: 
%     data_and_labels: a Map object mapping image 
%                      paths to labels.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%create a vector of image paths from selected images
[files, paths] = paths_vector();

%create the mapping from paths to labels with user input
data_and_labels = choose_labels(files, paths);

end





function [transition_matrix, paths_indices] = initialize_transition_matrix(data_and_labels)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function initializes the transition matrix and returns it and the 
% paths associated with the indices of the matrix.
%
% Parameter:
%     data_and_labels: a Map object mapping image paths to labels.
%
% Outputs: 
%    transition_matrix: a matrix mapping transition probabilities between 
%                       labels and other labels, initialized with zeros.
%    paths_indices: a vector of paths corresponding to the labels of 
%                   transition_matrix.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%create a set of keys in data_and_labels
paths_indices = keys(data_and_labels);

%initialize the transition matrix
transition_matrix = zeros(size(paths_indices, 2));

end





function [path_index1, path_index2, pairs_to_avoid] = choose_indices(paths_indices, pairs_to_avoid)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This funcion chooses two different indices to compare.
%
% Parameters: 
%    pairs_to_avoid: a matrix with ones to indicate points to not choose.
%    paths_indices: a vector of paths corresponding to the labels of 
%                   transition_matrix.
%
% Outputs:
%    path_index1: an integer representing a row index of
%                  transition_matrix.
%    path_index2: an integer representing a column index of
%                  transition_matrix.
%    pairs_to_avoid: a matrix with ones to indicate points to not choose.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%find the indices of the zeros in
[rows, ~] = find(~pairs_to_avoid);

%check if there are no unchecked values
if size(rows, 1) == 0
    
    %reset the pairs to avoid
    pairs_to_avoid = eye(size(zeros(size(paths_indices, 2))));
    
end

%calculate the sums of each row in pairs_to_avoid
row_sums = sum(pairs_to_avoid, 1);

%sort the indices 
[~, comp] = sort(row_sums);

%iterate over the indices in comparison_indices starting at the 2nd index
for i = 2:size(comp, 2)
    
    %check if the corresponding values in pairs_to_avoid are zero
    if pairs_to_avoid(comp(1), comp(i)) == 0 && pairs_to_avoid(comp(i), comp(1)) == 0
            
        %initialize path_index1 as comp(1)
        path_index1 = comp(1);

        %initialize path_index2 as comp(i)
        path_index2 = comp(i);
                    
        %set the value pairs_to_avoid(path_index1, path_index2) to one
        pairs_to_avoid(path_index1, path_index2) = 1;
        
        %set the value pairs_to_avoid(path_index2, path_index1) to one
        pairs_to_avoid(path_index2, path_index1) = 1;
        
        %break out of the for loop
        break
        
    end
        
end

end





function index1_to_index2 = compare_paths(path_index1, path_index2, path_indices)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function calculates the transition probability from path_index1 to
% path_index2.
%
% Parameters:
%    path_index1: an integer representing a row index of
%                  transition_matrix.
%    path_index2:  an integer representing a column index of
%                  transition_matrix.
%    paths_indices: a vector of paths corresponding to the labels  
%                   of transition_matrix.
%
% Output: 
%    index1_to_index2: the probability of transitioning from index1 to 
%                      index2.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%isolate the the image path associated with path_index1
path1 = char(path_indices(path_index1));

%isolate the the image path associated with path_index2
path2 = char(path_indices(path_index2));

%read in the first image
image1 = imread(path1);

%read in the second image
image2 = imread(path2);

%calculate the area of image1
area1 = size(image1, 1) * size(image1, 2);

%calculate the area of image2
area2 = size(image2, 1) * size(image2, 2);

%check if area1 is greater than area2
if area1 > area2
    
    %determine the ratio between area1 and area2
    ratio = area1 / area2;
    
    %rescale image2
    image2 = imresize(image2, sqrt(ratio));
    
elseif area1 < area2
        
    %determine the ratio between area2 and area1
    ratio = area2 / area1;
    
    %rescale image2
    image1 = imresize(image1, sqrt(ratio));
    
end
    
%display the two associated images
imshowpair(image1, image2, 'montage');

%clear the console
clc

%prompt the user to make a selection
user_selection = input('Press a for left, l for right, space bar for equal, then press enter: ', 's');

%close the figure
close all

%clear the console
clc

%check for the left image input
if user_selection == 'a'
    
    %set the transition probability value to .25
    index1_to_index2 = .25;
    
%check for the right image input
elseif user_selection == 'l'
    
    %set the transition probability value to .75
    index1_to_index2 = .75;

%check for the equal rating
elseif user_selection == ' '
    
    %set the transition probability value to .5
    index1_to_index2 = .5;

%run if no other case works
else
    
    %set the transition probability value to 0
    index1_to_index2 = 0;
    
end
    
end





function transition_matrix = update_transition_matrix(index1_to_index2, path_index1, path_index2, transition_matrix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function updates transition_matrix based on the probability 
% index1_to_index2.
%
% Parameters: 
%    index1_to_index2: the probability of transitioning from index1 to 
%                      index2.
%    path_index1: an integer representing a row index of
%                  transition_matrix.
%    path_index2:  an integer representing a column index of
%                  transition_matrix.
%    transition_matrix: a matrix mapping transition probabilities between 
%                       labels and other labels.
%
% Output: 
%    transition_matrix: the updated matrix mapping transition probabilities
%                       between labels and other labels.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%check if the probability of transitioning from index1 to index2 is not
%zero
if index1_to_index2 ~= 0
    
    %update the probability of transitioning from index1 to index1
    transition_matrix(path_index1, path_index1) = transition_matrix(path_index1, path_index1) + 1 - index1_to_index2;
    
    %update the probability of transitioning from index1 to index2
    transition_matrix(path_index1, path_index2) = transition_matrix(path_index1, path_index2) + index1_to_index2;
    
    %update the probability of transitioning from index2 to index1
    transition_matrix(path_index2, path_index1) = transition_matrix(path_index2, path_index1) + 1 - index1_to_index2;
    
    %update the probability of transitioning from index2 to index2
    transition_matrix(path_index2, path_index2) = transition_matrix(path_index2, path_index2) + index1_to_index2;
    
end    

end





function [transition_matrix, paths_indices] = select_preferences(data_and_labels)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function prompts the user to make selections between pairs 
% of options and creates a transition matrix based on the 
% selections.
%
% Parameter: 
%    data_and_labels: a Map object mapping images paths to labels.
%
% Outputs:
%    transition_matrix: a matrix mapping transition probabilities 
%                       between labels and other labels.
%    paths_indices: a vector of paths corresponding to the labels  
%                   of transition_matrix.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%initialize the transition matrix
[transition_matrix, paths_indices] = initialize_transition_matrix(data_and_labels);

%calculate the recommended number of comparisons
ideal_num = (size(transition_matrix, 1)^2 - size(transition_matrix, 1)) / 2;

%create the string to prompt the user for a number of comparisons
comparison_prompt = ['Input the number of comparisons you would like to do (the recommended number is ' num2str(ideal_num)  '): '];

%ask the user to input the number of comparisons to do
num_comparisons = input(comparison_prompt);

%initialize the pairs to avoid
pairs_to_avoid = eye(size(transition_matrix));
    
%complete the comparions
for i=1:num_comparisons 
    
    %choose two different, random indices to compare
    [path_index1, path_index2, pairs_to_avoid] = choose_indices(paths_indices, pairs_to_avoid);
    
    %calculate the transition probability from path_index1 to path_index2
    index1_to_index2 = compare_paths(path_index1, path_index2, paths_indices);
    
    %update transition_matrix based on the probability index1_to_index2
    transition_matrix = update_transition_matrix(index1_to_index2, ...
                        path_index1, path_index2, transition_matrix);
                    
end

end





function stationary_distribution = calculate_stationary_distribution(transition_matrix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function calculate the stationary distribution of the markov chain 
% represented with the transition matrix.
%
% Parameter:
%    transition_matrix: a matrix mapping transition probabilities 
%                       between labels and other labels.
% Output:
%    stationary_distribution: a vector used for ranking the images.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%normalize the rows of the transition matrix
transition_matrix = bsxfun(@rdivide, transition_matrix, sum(transition_matrix, 2));

%calculate the eigenvector
[stationary_distribution, ~] = eigs(transition_matrix', 1);

%normalize the stationary distribution
stationary_distribution = stationary_distribution / sum(stationary_distribution);

end





function display_rankings(stationary_distribution, path_indices, data_and_labels)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function displays the rankings and their associated scores to the 
% console.
%
% Parameters:
%    stationary_distribution: a vector used for ranking the images.
%    paths_indices: a vector of paths corresponding to the labels  
%                   of transition_matrix.
%    data_and_labels: a Map object mapping images paths to labels.
%
% Output: None
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%clear the console
clc

%display a ranking header
disp('Below are the rankings and the associated scores:');

%create a variable to store the last used rank
last_rank = 0;

%create a variable to store the last stationary distribution value
last_value = -1;

%iterate for the length of the stationary_distribution
for i = 1:size(stationary_distribution)
    
    %find the index of the maximum value
    max_index = find(stationary_distribution == max(stationary_distribution));
    
    %find the label associated with max_index
    label = data_and_labels(char(path_indices(max_index)));
    
    %determine the current maximum stationary distribution value
    max_value = stationary_distribution(max_index);
    
    %check if the last displayed rank had the same score (is a tie)
    if max_value == last_value
        
        %set rank equal to the last rank
        rank = last_rank;
    
    %run if the is not a tie
    else
        
        %set rank to the current index
        rank = i;
        
        %reset last_rank to the current rank for the next iteration
        last_rank = i;
        
        %reset last_value to the current max value for the next iteration
        last_value = max_value;
        
    end
    
    %check if the rank is less than 10, adding an extra space if yes
    if rank < 10
        
        %display the result to the console
        disp([num2str(rank) '  ' label ': ' num2str(max_value)]);
     
    %run if rank >= 10    
    else
        
        %display the result to the console
        disp([num2str(rank) ' ' label ': ' num2str(max_value)]);
        
    end
    
    %set the max value to -1 so it will not be chosen again
    stationary_distribution(max_index) = -1;
    
end

end





function calculate_and_display_results(transition_matrix, path_indices, data_and_labels)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function calculates the ranking of the images and displays the 
% results to the user.
%
% Parameters: 
%    transition_matrix: a matrix mapping transition probabilities 
%                       between labels and other labels.
%    paths_indices: a vector of paths corresponding to the labels  
%                   of transition_matrix.
%    data_and_labels: a Map object mapping images paths to labels.
%
% Outputs: None
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%calculate the stationary distribution
stationary_distribution = calculate_stationary_distribution(transition_matrix);

%display the rankings and their associated scores to the console
display_rankings(stationary_distribution, path_indices, data_and_labels);

end



