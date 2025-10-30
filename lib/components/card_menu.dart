import "package:app_pos_sqlite/utils/format_uang.dart";
import "package:flutter/material.dart";
import "../models/item.dart";

class CardMenu extends StatelessWidget {
  final Item item;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final int? totalPesanan;

  const CardMenu({
    super.key,
    required this.item,
    this.onAdd,
    this.onRemove,
    this.totalPesanan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4,),
                    Text(
                      item.category,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16,),
              Text(
                "Rp. ${item.price}",
              ),
              const SizedBox(width: 16,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(onAdd != null) IconButton(onPressed: onAdd, icon: Icon(Icons.add_circle_outline), padding: EdgeInsets.all(5), constraints: BoxConstraints(), color: Colors.blueAccent, iconSize: 16,),
                  const SizedBox(width: 4,),
                  if(onAdd != null || onRemove != null) Text(totalPesanan.toString()),
                  if(onRemove == null || onAdd == null) Text("${formatUang(totalPesanan! * item.price)}(${totalPesanan!})"),
                  const SizedBox(width: 4,),
                  if(onRemove != null) IconButton(onPressed: onRemove, icon: Icon(Icons.remove_circle_outline), padding: EdgeInsets.all(5), constraints: BoxConstraints(), color: Colors.blueAccent, iconSize: 16,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}