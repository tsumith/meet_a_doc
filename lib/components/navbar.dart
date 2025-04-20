import 'package:flutter/material.dart';

class BottomNavBarFb2 extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const BottomNavBarFb2({
    Key? key,
    required this.selectedIndex,
    required this.onTabChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BottomAppBar(
        elevation: 10,
        shape: const CircularNotchedRectangle(),
        color: Colors.white,
        child: SizedBox(
          height: 75,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.only(left: 2, right: 2, bottom: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconBottomBar(
                  text: "Home",
                  icon: Icons.home,
                  selected: selectedIndex == 0,
                  onPressed: () => onTabChange(0),
                ),
                IconBottomBar(
                  text: "Patients",
                  icon: Icons.group_outlined,
                  selected: selectedIndex == 1,
                  onPressed: () => onTabChange(1),
                ),
                IconBottomBar(
                  text: "appointments",
                  icon: Icons.calendar_today_outlined,
                  selected: selectedIndex == 2,
                  onPressed: () => onTabChange(2),
                ),
                IconBottomBar(
                  text: "Settings",
                  icon: Icons.settings_outlined,
                  selected: selectedIndex == 3,
                  onPressed: () => onTabChange(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IconBottomBar extends StatelessWidget {
  IconBottomBar({
    Key? key,
    required this.text,
    required this.icon,
    required this.selected,
    required this.onPressed,
  }) : super(key: key);

  final String text;
  final IconData icon;
  final bool selected;
  final Function() onPressed;

  final Color primaryColor = Color(0xFF108DA3);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          constraints: const BoxConstraints(minWidth: 72, minHeight: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 26,
                color: selected ? primaryColor : Colors.grey.shade500,
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected ? primaryColor : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
