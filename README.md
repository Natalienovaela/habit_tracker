## Getting Started
```shell
//Before you begin
flutter pub get
flutter pub run build_runner build

//To run the project
flutter clean
flutter pub get
flutter run
```

# habit_tracker
This habit tracker app has 3 tabs: Home, Category, and Rewards

## Home
Home serves as the medium for: 
- Daily habit logging, consisting of heat map, in which the darker the color the higher the completion rate.
- Remove habit (By sliding from left to right)
- Edit habit (By sliding from right to left)
## Category
Category serves as a habit organizer. Hence, users could work towards a certain "goal" or categorize their habits as needed. 
<br/><br/>In each specific category page, we could see:
- The habits sorted from the one with highest completion rate to the lowest
- The percentage of completion for each habit since the habit creation date.

## Rewards
Skinner's theory of operant conditioning, especially in his work on reinforcement (1938), emphasized that behavior that is reinforced (even by small rewards) is more likely to continue.
<br/><br/> Inspired by this theory, Rewards (or Wishlist) page serves as a motivator for the users. By completing habits, users could get coins which they could use to redeem their rewards/wishlist. This serves as "mini reward" to motivate the user to stick to his habit. 

## Future Improvement
1. Cute pet reminder widget! 
Reminder/Notification will help users in sticking to their habits. Instead of just sending users reminder notification, we could create a pet widget (that is on trend recently) to help remind users to log habit. 
2. Analytics 📊 
Users should be able to view the monthly summary of the habits logged. In addition, by clicking on specific date on the heat map, users should be able to see what habits they did, or did not, complete in the past.

## Pictures
<img width="334" alt="Home" src="https://github.com/user-attachments/assets/a97ca1aa-e324-4697-98ba-fd732ebe8b19" />
<img width="334" alt="Category" src="https://github.com/user-attachments/assets/634a5259-ce91-4053-9d3e-1e0eebb6512d" />
<img width="332" alt="Reward" src="https://github.com/user-attachments/assets/a93dc449-0711-4e81-aed8-be5e328a26dd" />

