# rubocop-for-checking-difference-between-model-and-schema
This is a custom cop for checking a difference between model and schema using AST(Abstract Syntax Tree).

## Why did I create this cop
In the project of a company I'm belonging to, an error occurred in the production environment.

A foreign key doesn't have "null: false" option in schema.rb. Besides, the corresponding model doesn't have "optional: true" for the association.
As a result, the model required user to input the associated object, even though the form for uses didn't have such field, leading to an error.
Want to avoid similar future issues by implementing this cop.

## How does this cop resolve the issue
Briefly speaking, the custom cop read schema.rb and find the table I want to check. Simultaneously, the setting of "belongs to" method in the model.
If the foreign key doesn't have "null: false" option in the table and the belongs to method doesn't have "optional: true", the cop works.

## Points I focused on in this cop
1.  Time complexity
   The cop's time complexity is O(N). Hash is used to decrease it. It would be O(N^2) without the hash because one belongs to method need to be compared with the schema.
  
2.  Open Closed principle
   In rubocop, there is a rule "one file, one rule" for easy scaling. Therefore, the cop rule is very specific. If we want to increase rules, we need to create new file.

## Test cases for this cop

|     | 'null false' exists | 'null false' not exists |
| --- | --- | --- |
| 'optional true' exists   | error but it can be caught in DB layer   |  pass  |
| 'optional true' not exists | pass   |  caught by this custom cop   | 


