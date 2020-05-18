'''10.Winning Ticket
Lottery is exciting. What is not, is checking a million tickets for winnings only by hand. So, you are given the task to create a program which
automatically checks if a ticket is a winner.
You are given a collection of tickets separated by commas and spaces. You need to check every one of them if it has a winning combination of symbols.
A valid ticket should have exactly 20 characters. The winning symbols are '@', '#', '$' and '^'. But in order for a ticket to be a winner the symbol
should uninterruptedly repeat for at least 6 times in both the tickets left half and the tickets right half.
For example, a valid winning ticket should be something like this:

"Cash$$$$$$Ca$$$$$$sh"

The left half "Cash$$$$$$" contains "$$$$$$", which is also contained in the tickets right half "Ca$$$$$$sh". A winning ticket should contain symbols
repeating up to 10 times in both halves, which is considered a Jackpot (for example: "$$$$$$$$$$$$$$$$$$$$").

Input
The input will be read from the console. The input consists of a single line containing all tickets separated by commas and one or more white spaces
in the format:
"{ticket}, {ticket}, … {ticket}"

Output
Print the result for every ticket in the order of their appearance, each on a separate line in the format:
Invalid ticket - "invalid ticket"
No match - "ticket "{ticket}" - no match"
Match with length 6 to 9 - "ticket "{ticket}" - {match length}{match symbol}"
Match with length 10 - "ticket "{ticket}" - {match length}{match symbol} Jackpot!"

Constrains
Number of tickets will be in range [0 … 100]

Examples
Input
Output

Cash$$$$$$Ca$$$$$$sh
ticket "Cash$$$$$$Ca$$$$$$sh" - 6$

$$$a$$$$$$$$$$$$$$$$, aabb  , th@@@@@@eemo@@@@@@ey
ticket "$$$$$$$$$$$$$$$$$$$$" - 10$ Jackpot!
invalid ticket
ticket "th@@@@@@eemo@@@@@@ey" - 6@

$$$$$$$$$$$$$$$$$$$$   ,   aabb  ,     @@@@@@^^^^mo^^^^^^ee
t@@^^^^^^emo@@^^^^^^

validticketnomatch:(
ticket "validticketnomatch:(" - no match
'''

tickets_1 = input().split(', ')
tickets_2 = []

for i in tickets_1:
    if i != '':
     tickets_2.append(i)


tickets = ['' for i in range(len(tickets_2))  ]
#print(tickets)


for i in range(len(tickets_2)):
   if len(tickets_2) == 20:
       tickets.append(tickets_2[i])
   else:
       for j in range(len(tickets_2[i])):
         if tickets_2[i][j] != ' ':
           tickets[i] = tickets[i] + tickets_2[i][j]



#print(tickets_2)
#print(tickets)

for k in range(len(tickets)):


   side_left = ''
   side_right = ''


   if len(tickets[k]) == 20:
            side_left = tickets[k][:10]
            side_right = tickets[k][10:20]

            #print(tickets)
            #print(side_right)
           #print(side_left)

            counter = 0
            char = 0

            for i in range(len(side_left)):
                if ord(side_left[i]) == 64 or ord(side_left[i]) == 35 or ord(side_left[i]) == 36 or ord(side_left[i]) == 94:
                    char = ord(side_left[i])
                    counter =1
                    if i < 5:
                      for j in range(i+1,len(side_left)):
                         if ord(side_left[j]) == char:
                             counter +=1
                         else:
                               if counter < 6:
                                  counter = 0 # TO CHECK THE UNINTERUPTEBILITY !!!   here the ticket is invalid, no reason to check the right side
                    if 6 <= counter <= 10:
                        break


            counter_right = 0

            for i in range(len(side_right)):
                if ord(side_right[i]) == char and i < 5:
                    counter_right =1
                    for j in range(i+1, len(side_right)):
                        if ord(side_right[j]) == char:
                            counter_right +=1
                        else:
                            if counter_right < 6:
                               counter_right=0

                    if 6 <= counter <= 10:
                        break

            if 6 <= counter <= 9 and 6 <= counter_right <=9:
                     print(f'ticket "{tickets[k]}" - {counter_right}{chr(char)}')
            elif counter_right == counter and counter_right == 10 :
                    print(f'ticket "{tickets[k]}" - {counter_right}{chr(char)} Jackpot!')
            elif (counter_right == 10 and 6<= counter <= 9):
                  print(f'ticket "{tickets[k]}" - {counter}{chr(char)}')
            elif (counter == 10 and 6 <= counter_right <= 9):
                    print(f'ticket "{tickets[k]}" - {counter_right}{chr(char)}')
            else:# counter < 6 or counter_right < 6:
                    print(f'ticket "{tickets[k]}" - no match')
   else: # THE LENGHT IS DIFFERENT FROM 20
            print(f"invalid ticket")




